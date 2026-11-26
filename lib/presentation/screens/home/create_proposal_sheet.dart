import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/item_model.dart';
import '../../data/models/swap_proposal_model.dart';
import '../../state/items_provider.dart';
import '../../state/proposal_provider.dart';
import '../widgets/custom_button.dart';

class CreateProposalSheet extends StatefulWidget {
  final ItemModel targetItem;
  final ProposalType proposalType;

  const CreateProposalSheet({
    super.key,
    required this.targetItem,
    required this.proposalType,
  });

  @override
  State<CreateProposalSheet> createState() => _CreateProposalSheetState();
}

class _CreateProposalSheetState extends State<CreateProposalSheet> {
  String? _selectedMyItemId;
  final _noteController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.proposalType == ProposalType.swap) {
      context.read<ItemsProvider>().fetchMyItems();
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (widget.proposalType == ProposalType.swap && _selectedMyItemId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih salah satu barang Anda untuk ditukarkan')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final proposalProv = context.read<ProposalProvider>();

    final success = await proposalProv.sendProposal(
      type: widget.proposalType,
      targetItemId: widget.targetItem.id,
      offeredItemId: _selectedMyItemId,
      ownerId: widget.targetItem.ownerId,
      note: _noteController.text.trim(),
    );

    setState(() => _isSubmitting = false);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? (widget.proposalType == ProposalType.swap
                    ? 'Tawaran barter berhasil dikirimkan!'
                    : 'Permintaan donasi berhasil diajukan!')
                : 'Gagal mengirimkan pengajuan. Coba lagi.',
          ),
          backgroundColor: success ? AppColors.primary : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final myItems = context.watch<ItemsProvider>().myItems.where((i) => i.id != widget.targetItem.id).toList();

    final isSwap = widget.proposalType == ProposalType.swap;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 20,
        right: 20,
        top: 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isSwap ? Icons.swap_horiz : Icons.volunteer_activism,
                  color: isSwap ? AppColors.swapColor : AppColors.shareColor,
                ),
                const SizedBox(width: 8),
                Text(
                  isSwap ? 'Ajukan Pertukaran (Swap)' : 'Ajukan Permintaan Donasi',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              isSwap
                  ? 'Pilih salah satu barang milik Anda untuk ditawarkan kepada pemilik:'
                  : 'Tuliskan alasan atau rencana penggunaan barang ini kepada pemilik:',
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),

            // Swap: Item picker
            if (isSwap) ...[
              if (myItems.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: const Text(
                    'Anda belum memiliki barang aktif untuk ditukarkan. Pasang barang terlebih dahulu di tab Posting (+).',
                    style: TextStyle(color: Colors.brown, fontSize: 13),
                  ),
                )
              else
                DropdownButtonFormField<String>(
                  value: _selectedMyItemId,
                  hint: const Text('Pilih barang Anda untuk dibarter'),
                  items: myItems.map((item) {
                    return DropdownMenuItem<String>(
                      value: item.id,
                      child: Text(
                        '${item.title} (${item.condition})',
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedMyItemId = val),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.inventory_2_outlined),
                  ),
                ),
              const SizedBox(height: 16),
            ],

            // Note field
            TextFormField(
              controller: _noteController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: isSwap
                    ? 'Catatan tambahan (misal: "Barang saya masih mulus, bisa janjian di kantin kampus...")'
                    : 'Ceritakan mengapa barang ini bermanfaat untuk Anda...',
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: isSwap ? 'Kirim Tawaran Barter' : 'Kirim Permintaan Barang',
                color: isSwap ? AppColors.swapColor : AppColors.shareColor,
                isLoading: _isSubmitting,
                onPressed: _submit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
