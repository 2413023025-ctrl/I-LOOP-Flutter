import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_categories.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/item_model.dart';
import '../../state/items_provider.dart';
import '../widgets/custom_button.dart';

class PostItemScreen extends StatefulWidget {
  const PostItemScreen({super.key});

  @override
  State<PostItemScreen> createState() => _PostItemScreenState();
}

class _PostItemScreenState extends State<PostItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _swapWishlistController = TextEditingController();
  final _areaNotesController = TextEditingController();

  ListingType _listingType = ListingType.sell;
  String _category = AppCategories.items[1]; // Skip 'Semua'
  String _condition = AppCategories.conditions[1];
  String _city = IndonesianCities.list.first;
  final List<File> _images = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _swapWishlistController.dispose();
    _areaNotesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      setState(() => _images.add(File(picked.path)));
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unggah minimal 1 foto barang')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final itemsProv = context.read<ItemsProvider>();

    final price = double.tryParse(_priceController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0;

    final success = await itemsProv.createItem(
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      listingType: _listingType,
      price: price,
      swapWishlist: _listingType == ListingType.swap ? _swapWishlistController.text.trim() : null,
      category: _category,
      condition: _condition,
      city: _city,
      areaNotes: _areaNotesController.text.trim(),
      imageFiles: _images,
    );

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Barang Anda berhasil dipasang!'),
            backgroundColor: AppColors.primary,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(itemsProv.errorMessage ?? 'Gagal memasang barang. Coba lagi.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Pasang Barang Baru'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo Picker Row
              const Text('Foto Barang (Maks. 5 Foto)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    if (_images.length < 5)
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 100,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo, color: AppColors.primary),
                              SizedBox(height: 4),
                              Text('Tambah', style: TextStyle(fontSize: 11, color: AppColors.primary)),
                            ],
                          ),
                        ),
                      ),
                    ..._images.asMap().entries.map((entry) {
                      return Stack(
                        children: [
                          Container(
                            width: 100,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                image: FileImage(entry.value),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 16,
                            child: GestureDetector(
                              onTap: () => setState(() => _images.removeAt(entry.key)),
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close, size: 14, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Mode Transaksi Selection
              const Text('Pilih Mode Transaksi', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildTypeOption(
                      label: 'Jual Beli',
                      type: ListingType.sell,
                      color: AppColors.sellColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildTypeOption(
                      label: 'Tukar (Swap)',
                      type: ListingType.swap,
                      color: AppColors.swapColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildTypeOption(
                      label: 'Donasi (Share)',
                      type: ListingType.share,
                      color: AppColors.shareColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Judul Barang
              const Text('Judul Barang', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'Contoh: Buku Kuliah Pemrograman Python Bekas Bagus',
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              // Dynamic Price / Swap Wishlist Field
              if (_listingType == ListingType.sell) ...[
                const Text('Harga Barang (Rp)', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    prefixText: 'Rp ',
                    hintText: '50000',
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 16),
              ] else if (_listingType == ListingType.swap) ...[
                const Text('Barang yang Diinginkan untuk Ditukar', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _swapWishlistController,
                  decoration: const InputDecoration(
                    hintText: 'Contoh: Mau tukar dengan kalkulator ilmiah atau novel',
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 16),
              ],

              // Kategori
              const Text('Kategori', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _category,
                items: AppCategories.items.sublist(1).map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat));
                }).toList(),
                onChanged: (val) => setState(() => _category = val!),
              ),
              const SizedBox(height: 16),

              // Kondisi
              const Text('Kondisi Barang', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _condition,
                items: AppCategories.conditions.map((c) {
                  return DropdownMenuItem(value: c, child: Text(c, overflow: TextOverflow.ellipsis));
                }).toList(),
                onChanged: (val) => setState(() => _condition = val!),
              ),
              const SizedBox(height: 16),

              // Kota Lokasi & Catatan Area
              const Text('Kota Lokasi COD / Serah Terima', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _city,
                items: IndonesianCities.list.map((ct) {
                  return DropdownMenuItem(value: ct, child: Text(ct));
                }).toList(),
                onChanged: (val) => setState(() => _city = val!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _areaNotesController,
                decoration: const InputDecoration(
                  hintText: 'Catatan area / kampus (misal: Kampus UI Depok / Sekitar Stasiun)',
                ),
              ),
              const SizedBox(height: 16),

              // Deskripsi
              const Text('Deskripsi Lengkap', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Jelaskan kondisi minus jika ada, kelengkapan, dan alasan tidak lagi dipakai...',
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: 'Pasang Barang Sekarang',
                  isLoading: _isLoading,
                  onPressed: _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeOption({
    required String label,
    required ListingType type,
    required Color color,
  }) {
    final isSelected = _listingType == type;
    return GestureDetector(
      onTap: () => setState(() => _listingType = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
