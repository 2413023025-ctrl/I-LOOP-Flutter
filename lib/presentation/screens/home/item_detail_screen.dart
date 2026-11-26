import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/item_model.dart';
import '../../../data/models/swap_proposal_model.dart';
import '../../../data/repositories/item_repository.dart';
import '../../../state/auth_provider.dart';
import '../../../state/chat_provider.dart';
import '../../widgets/custom_button.dart';
import '../chat/chat_room_screen.dart';
import 'create_proposal_sheet.dart';

class ItemDetailScreen extends StatefulWidget {
  final String itemId;

  const ItemDetailScreen({super.key, required this.itemId});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  final ItemRepository _repo = ItemRepository();
  ItemModel? _item;
  bool _isLoading = true;
  int _activeImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() => _isLoading = true);
    final itm = await _repo.getItemById(widget.itemId);
    if (mounted) {
      setState(() {
        _item = itm;
        _isLoading = false;
      });
    }
  }

  void _openChat(String targetUserId) async {
    final chatProv = context.read<ChatProvider>();
    final room = await chatProv.getOrCreateRoom(
      targetUserId: targetUserId,
      itemId: widget.itemId,
    );
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatRoomScreen(
            chatRoomId: room.id,
            targetUserName: _item?.owner?.fullName ?? 'Pemilik Barang',
            itemTitle: _item?.title,
          ),
        ),
      );
    }
  }

  void _openProposal(ProposalType type) {
    if (_item == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CreateProposalSheet(
        targetItem: _item!,
        proposalType: type,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    if (_item == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Barang tidak ditemukan atau telah dihapus.')),
      );
    }

    final item = _item!;
    final currentUserId = context.read<AuthProvider>().currentUser?.id;
    final isMyItem = currentUserId == item.ownerId;

    final imageList = item.images.isNotEmpty
        ? item.images
        : (item.primaryImageUrl != null ? [item.primaryImageUrl!] : <String>[]);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tautan barang berhasil disalin')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Carousel / Banner
            if (imageList.isNotEmpty)
              Stack(
                children: [
                  SizedBox(
                    height: 280,
                    child: PageView.builder(
                      itemCount: imageList.length,
                      onPageChanged: (idx) => setState(() => _activeImageIndex = idx),
                      itemBuilder: (context, index) {
                        return CachedNetworkImage(
                          imageUrl: imageList[index],
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(color: Colors.grey[200]),
                          errorWidget: (_, __, ___) => const Center(
                            child: Icon(Icons.image_not_supported, color: Colors.grey),
                          ),
                        );
                      },
                    ),
                  ),
                  if (imageList.length > 1)
                    Positioned(
                      bottom: 12,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_activeImageIndex + 1} / ${imageList.length}',
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                ],
              )
            else
              Container(
                height: 200,
                color: const Color(0xFFE8F5E9),
                child: const Center(
                  child: Icon(Icons.recycling, size: 64, color: AppColors.primaryLight),
                ),
              ),

            // Item Details Body
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges Row
                  Row(
                    children: [
                      _buildListingTypeBadge(item.listingType),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          item.condition,
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Title & Price
                  Text(
                    item.title,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (item.listingType == ListingType.sell)
                    Text(
                      CurrencyFormatter.formatRupiah(item.price),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    )
                  else if (item.listingType == ListingType.swap)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.swapColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.swapColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.swap_calls, color: AppColors.swapColor),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Ingin ditukar dengan:',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.swapColor,
                                  ),
                                ),
                                Text(
                                  item.swapWishlist ?? 'Terbuka tawaran apa saja',
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.shareColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.shareColor.withOpacity(0.3)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.volunteer_activism, color: AppColors.shareColor),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Barang ini dibagikan gratis untuk yang membutuhkan!',
                              style: TextStyle(
                                color: AppColors.shareColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 12),

                  // Owner Profile Card
                  if (item.owner != null) ...[
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: AppColors.primary.withOpacity(0.15),
                          child: Text(
                            item.owner!.fullName.isNotEmpty ? item.owner!.fullName[0] : 'U',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.owner!.fullName,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              Text(
                                '${item.city}${item.areaNotes != null ? " • ${item.areaNotes}" : ""}',
                                style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.eco, size: 14, color: AppColors.primary),
                              const SizedBox(width: 4),
                              Text(
                                '${item.owner!.itemsSavedCount} terselamatkan',
                                style: const TextStyle(fontSize: 11, color: AppColors.primary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                  ],

                  // Description Section
                  const SizedBox(height: 12),
                  const Text(
                    'Deskripsi Barang',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 24),
                  // Category Info
                  Row(
                    children: [
                      const Icon(Icons.category_outlined, size: 18, color: AppColors.textMuted),
                      const SizedBox(width: 8),
                      Text(
                        'Kategori: ${item.category}',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 80), // Padding for bottom action bar
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              if (isMyItem)
                Expanded(
                  child: CustomButton(
                    text: 'Kelola Barang Saya',
                    isOutlined: true,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Anda dapat mengubah status barang di tab Profil')),
                      );
                    },
                  ),
                )
              else ...[
                // Chat button
                OutlinedButton(
                  onPressed: () => _openChat(item.ownerId),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Icon(Icons.chat_bubble_outline, color: AppColors.primary),
                ),
                const SizedBox(width: 12),

                // Primary Action Button (Beli / Barter / Minta)
                Expanded(
                  child: item.listingType == ListingType.swap
                      ? CustomButton(
                          text: 'Ajukan Barter',
                          color: AppColors.swapColor,
                          icon: Icons.swap_horiz,
                          onPressed: () => _openProposal(ProposalType.swap),
                        )
                      : item.listingType == ListingType.share
                          ? CustomButton(
                              text: 'Minta Donasi',
                              color: AppColors.shareColor,
                              icon: Icons.volunteer_activism,
                              onPressed: () => _openProposal(ProposalType.share),
                            )
                          : CustomButton(
                              text: 'Beli via Janjian COD',
                              icon: Icons.handshake,
                              onPressed: () => _openChat(item.ownerId),
                            ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListingTypeBadge(ListingType type) {
    Color color = AppColors.sellColor;
    String label = 'Jual Beli';

    if (type == ListingType.swap) {
      color = AppColors.swapColor;
      label = 'Tukar / Barter';
    } else if (type == ListingType.share) {
      color = AppColors.shareColor;
      label = 'Donasi Gratis';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
