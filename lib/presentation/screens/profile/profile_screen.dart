import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_categories.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/item_model.dart';
import '../../../data/models/profile_model.dart';
import '../../../state/auth_provider.dart';
import '../../../state/items_provider.dart';
import '../auth/login_screen.dart';
import '../../widgets/eco_badge_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().loadCurrentProfile();
      context.read<ItemsProvider>().fetchMyItems();
    });
  }

  void _showEditProfileDialog(BuildContext context, ProfileModel? currentProfile) {
    final nameController = TextEditingController(text: currentProfile?.fullName ?? '');
    final cityController = TextEditingController(text: currentProfile?.city ?? '');
    final campusController = TextEditingController(text: currentProfile?.campusOrArea ?? '');
    final phoneController = TextEditingController(text: currentProfile?.phoneNumber ?? '');
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Atur Kota / Edit Profil',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Ubah kota domisili agar filter barang di sekitar Anda lebih akurat.',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      const Divider(height: 24),

                      // Nama Lengkap
                      const Text('Nama Lengkap', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          hintText: 'Nama lengkap Anda',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Nama tidak boleh kosong';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Kota / Tempat Tinggal (Wajib)
                      Row(
                        children: const [
                          Text('Kota / Tempat Tinggal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          SizedBox(width: 4),
                          Text('*', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: cityController,
                        decoration: InputDecoration(
                          hintText: 'Contoh: Bandar Lampung, Bandung, dll.',
                          prefixIcon: const Icon(Icons.location_city_outlined),
                          suffixIcon: PopupMenuButton<String>(
                            icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
                            tooltip: 'Pilih dari daftar kota',
                            onSelected: (String selectedCity) {
                              setModalState(() {
                                cityController.text = selectedCity;
                              });
                            },
                            itemBuilder: (_) {
                              return IndonesianCities.list.map((String city) {
                                return PopupMenuItem<String>(
                                  value: city,
                                  child: Text(city),
                                );
                              }).toList();
                            },
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Kota tempat tinggal wajib diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),

                      // Quick Chips Pilihan Kota
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            'Bandar Lampung',
                            'Jakarta Selatan',
                            'Bandung',
                            'Surabaya',
                            'Yogyakarta',
                          ].map((city) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: ActionChip(
                                label: Text(city, style: const TextStyle(fontSize: 11)),
                                backgroundColor: AppColors.primary.withOpacity(0.08),
                                onPressed: () {
                                  setModalState(() {
                                    cityController.text = city;
                                  });
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Area / Kampus (Opsional)
                      const Text('Area / Kampus / Kecamatan (Opsional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: campusController,
                        decoration: const InputDecoration(
                          hintText: 'Contoh: UNILA, ITB, Sekitar Sukarame',
                          prefixIcon: Icon(Icons.school_outlined),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Nomor Telepon (Opsional)
                      const Text('Nomor WhatsApp (Opsional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          hintText: 'Contoh: 081234567890',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Tombol Simpan
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (!formKey.currentState!.validate()) return;

                            final success = await this.context.read<AuthProvider>().updateProfile(
                              fullName: nameController.text.trim(),
                              city: cityController.text.trim(),
                              campusOrArea: campusController.text.trim().isEmpty ? null : campusController.text.trim(),
                              phoneNumber: phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
                            );

                            if (mounted) {
                              Navigator.pop(ctx);
                              if (success) {
                                ScaffoldMessenger.of(this.context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Profil dan kota tempat tinggal berhasil disimpan!'),
                                    backgroundColor: AppColors.primary,
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(this.context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Gagal menyimpan perubahan profil.'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          child: const Text('Simpan Perubahan', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar dari akun I\'LOOP?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<AuthProvider>().signOut();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final profile = auth.currentProfile;
    final itemsProv = context.watch<ItemsProvider>();

    final String? userCity = profile?.city;
    final bool hasCity = userCity != null && userCity.trim().isNotEmpty && userCity != 'Kota belum diatur';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profil & Dampak Sirkular'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            tooltip: 'Keluar',
            onPressed: _confirmLogout,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await auth.loadCurrentProfile();
          await itemsProv.fetchMyItems();
        },
        color: AppColors.primary,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // User info card with Edit Kota / Edit Profil Button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: AppColors.primary.withOpacity(0.15),
                        child: Text(
                          profile != null && profile.fullName.isNotEmpty ? profile.fullName[0].toUpperCase() : 'U',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile?.fullName ?? 'Pengguna I\'LOOP',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 14, color: AppColors.primary),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    hasCity
                                        ? '${profile!.city}${profile.campusOrArea != null ? " • ${profile.campusOrArea}" : ""}'
                                        : 'Kota belum diatur',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: hasCity ? FontWeight.w600 : FontWeight.normal,
                                      color: hasCity ? AppColors.textPrimary : Colors.orange[800],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              auth.currentUser?.email ?? '',
                              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Tombol Atur Kota / Edit Profil (Menggantikan status teks statis)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.edit_location_alt_outlined, size: 18),
                      label: Text(
                        hasCity ? 'Atur Kota / Edit Profil' : 'Atur Kota Tempat Tinggal',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      onPressed: () => _showEditProfileDialog(context, profile),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Eco Impact Badge Card
            EcoBadgeWidget(itemsSaved: profile?.itemsSavedCount ?? 0),
            const SizedBox(height: 24),

            // My Items Header
            Row(
              children: [
                const Text(
                  'Barang Saya',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${itemsProv.myItems.length}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (itemsProv.myItems.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Center(
                  child: Text(
                    'Anda belum memasang barang apapun.\nGunakan tombol (+) di tengah untuk mulai memasang barang.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                ),
              )
            else
              ...itemsProv.myItems.map((item) {
                final isCompleted = item.status == ItemStatus.completed;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.title,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isCompleted ? Colors.green[100] : Colors.blue[50],
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                isCompleted ? 'Selesai Sirkular' : 'Tersedia',
                                style: TextStyle(
                                  color: isCompleted ? Colors.green[800] : Colors.blue[800],
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Tipe: ${item.listingType.name.toUpperCase()} • Kategori: ${item.category} • Kota: ${item.city}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (!isCompleted)
                              ElevatedButton.icon(
                                onPressed: () {
                                  itemsProv.updateItemStatus(item.id, ItemStatus.completed);
                                  auth.loadCurrentProfile();
                                },
                                icon: const Icon(Icons.check_circle_outline, size: 16),
                                label: const Text('Tandai Selesai'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  textStyle: const TextStyle(fontSize: 12),
                                ),
                              ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                              tooltip: 'Hapus Barang',
                              onPressed: () {
                                itemsProv.deleteItem(item.id);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
