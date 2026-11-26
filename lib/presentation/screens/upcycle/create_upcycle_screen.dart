import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../state/upcycle_provider.dart';
import '../../widgets/custom_button.dart';

class CreateUpcycleScreen extends StatefulWidget {
  const CreateUpcycleScreen({super.key});

  @override
  State<CreateUpcycleScreen> createState() => _CreateUpcycleScreenState();
}

class _CreateUpcycleScreenState extends State<CreateUpcycleScreen> {
  final _titleController = TextEditingController();
  final _materialsController = TextEditingController();
  final _stepsController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  File? _coverImage;
  bool _isUploading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _materialsController.dispose();
    _stepsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      setState(() => _coverImage = File(picked.path));
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_coverImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih foto cover panduan terlebih dahulu')),
      );
      return;
    }

    setState(() => _isUploading = true);
    final upcycleProv = context.read<UpcycleProvider>();

    final success = await upcycleProv.createPost(
      title: _titleController.text.trim(),
      materials: _materialsController.text.trim(),
      steps: _stepsController.text.trim(),
      coverImage: _coverImage!,
    );

    setState(() => _isUploading = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Panduan DIY berhasil dipublikasikan!'),
            backgroundColor: AppColors.upcycleColor,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(upcycleProv.errorMessage ?? 'Gagal mengunggah postingan'),
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
        title: const Text('Tulis Panduan Upcycle'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo picker
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border, style: BorderStyle.solid),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _coverImage != null
                      ? Image.file(_coverImage!, fit: BoxFit.cover)
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo_outlined, size: 40, color: AppColors.upcycleColor),
                            SizedBox(height: 8),
                            Text(
                              'Unggah Foto Sampul Tutorial',
                              style: TextStyle(
                                color: AppColors.upcycleColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              const Text('Judul Panduan', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'Contoh: Mengubah Celana Jeans Bekas Menjadi Tote Bag',
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 18),

              // Materials
              const Text('Bahan & Alat', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _materialsController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: '- Celana jeans bekas\n- Benang jahit & jarum\n- Gunting kain',
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 18),

              // Steps
              const Text('Langkah-Langkah Pembuatan', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _stepsController,
                maxLines: 6,
                decoration: const InputDecoration(
                  hintText: '1. Potong bagian kaki celana sepanjang 40 cm...\n2. Jahit bagian bawah...\n3. Buat tali pegangan...',
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: 'Publikasikan Panduan',
                  color: AppColors.upcycleColor,
                  isLoading: _isUploading,
                  onPressed: _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
