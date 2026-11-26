import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/models/swap_proposal_model.dart';
import '../../state/chat_provider.dart';
import '../../state/proposal_provider.dart';
import 'chat_room_screen.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().fetchRooms();
      context.read<ProposalProvider>().fetchAllProposals();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Obrolan & Aktivitas'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Pesan'),
            Tab(text: 'Proposal Barter & Donasi'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildChatList(),
          _buildProposalList(),
        ],
      ),
    );
  }

  Widget _buildChatList() {
    final chatProv = context.watch<ChatProvider>();

    if (chatProv.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (chatProv.rooms.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 56, color: Colors.grey),
            SizedBox(height: 12),
            Text('Belum ada pesan obrolan', style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => chatProv.fetchRooms(),
      color: AppColors.primary,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: chatProv.rooms.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final room = chatProv.rooms[index];
          final otherName = room.otherUser?.fullName ?? 'Pengguna I\'LOOP';

          return ListTile(
            tileColor: Colors.white,
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.12),
              child: Text(
                otherName.isNotEmpty ? otherName[0] : 'U',
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(otherName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
              room.lastMessage ?? 'Memulai obrolan...',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            trailing: room.lastMessageAt != null
                ? Text(
                    CurrencyFormatter.formatShortDate(room.lastMessageAt!),
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                  )
                : null,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatRoomScreen(
                    chatRoomId: room.id,
                    targetUserName: otherName,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildProposalList() {
    final proposalProv = context.watch<ProposalProvider>();

    if (proposalProv.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    final incoming = proposalProv.incomingProposals;
    final outgoing = proposalProv.outgoingProposals;

    if (incoming.isEmpty && outgoing.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.swap_horizontal_circle_outlined, size: 56, color: Colors.grey),
            SizedBox(height: 12),
            Text('Belum ada proposal masuk atau diajukan', style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => proposalProv.fetchAllProposals(),
      color: AppColors.primary,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (incoming.isNotEmpty) ...[
            const Text(
              'Proposal Masuk (Permintaan dari Pengguna Lain)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 10),
            ...incoming.map((prop) => _buildProposalCard(prop, isIncoming: true)),
            const SizedBox(height: 20),
          ],
          if (outgoing.isNotEmpty) ...[
            const Text(
              'Proposal Keluar (Yang Anda Ajukan)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 10),
            ...outgoing.map((prop) => _buildProposalCard(prop, isIncoming: false)),
          ],
        ],
      ),
    );
  }

  Widget _buildProposalCard(SwapProposalModel prop, {required bool isIncoming}) {
    Color statusColor = Colors.orange;
    String statusText = 'Menunggu Respon';

    if (prop.status == ProposalStatus.accepted) {
      statusColor = Colors.green;
      statusText = 'Diterima';
    } else if (prop.status == ProposalStatus.rejected) {
      statusColor = Colors.red;
      statusText = 'Ditolak';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: prop.proposalType == ProposalType.swap ? AppColors.swapColor : AppColors.shareColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    prop.proposalType == ProposalType.swap ? 'Tukar / Barter' : 'Permintaan Donasi',
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Barang Target: ${prop.targetItem?.title ?? "Barang"}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            if (prop.offeredItem != null) ...[
              const SizedBox(height: 4),
              Text(
                'Ditukar dengan: ${prop.offeredItem!.title}',
                style: const TextStyle(color: AppColors.swapColor, fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ],
            if (prop.note != null && prop.note!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                'Catatan: "${prop.note}"',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
              ),
            ],
            if (isIncoming && prop.status == ProposalStatus.pending) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      context.read<ProposalProvider>().updateStatus(prop.id, ProposalStatus.rejected);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    ),
                    child: const Text('Tolak'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ProposalProvider>().updateStatus(prop.id, ProposalStatus.accepted);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    ),
                    child: const Text('Terima'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
