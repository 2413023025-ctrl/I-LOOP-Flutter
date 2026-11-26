import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_categories.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/item_model.dart';
import '../../../state/auth_provider.dart';
import '../../../state/items_provider.dart';
import '../../widgets/item_card.dart';
import 'item_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ItemsProvider>().fetchItems();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemsProvider = context.watch<ItemsProvider>();
    final auth = context.watch<AuthProvider>();
    final profile = auth.currentProfile;

    final String userCity = (profile?.city != null && profile!.city.trim().isNotEmpty)
        ? profile.city.trim()
        : 'Bandar Lampung';

    final bool isFilteredByMyCity = itemsProvider.selectedCity.toLowerCase() == userCity.toLowerCase();
    final bool isAllCities = itemsProvider.selectedCity == 'Semua Kota';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.recycling, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 10),
            const Text(
              "I'LOOP",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: AppColors.primary,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => itemsProvider.fetchItems(),
        color: AppColors.primary,
        child: CustomScrollView(
          slivers: [
            // Info Daerah & Filter Lokasi Pengguna
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                child: Column(
                  children: [
                    // Banner info kota pengguna saat ini
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on, color: AppColors.primary, size: 18),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text.rich(
                              TextSpan(
                                text: 'Daerah Anda: ',
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                children: [
                                  TextSpan(
                                    text: userCity,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            isAllCities ? 'Semua Kota' : 'Filter Aktif: ${itemsProvider.selectedCity}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Filter Tab Cepat Berdasarkan Kota (Semua Kota vs Kota Saya)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ChoiceChip(
                            label: const Text('Semua Kota'),
                            selected: isAllCities,
                            selectedColor: AppColors.primary,
                            labelStyle: TextStyle(
                              color: isAllCities ? Colors.white : AppColors.textPrimary,
                              fontWeight: isAllCities ? FontWeight.bold : FontWeight.normal,
                              fontSize: 12,
                            ),
                            backgroundColor: Colors.grey[100],
                            onSelected: (_) {
                              itemsProvider.setCity('Semua Kota');
                            },
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            avatar: Icon(
                              Icons.my_location,
                              size: 14,
                              color: isFilteredByMyCity ? Colors.white : AppColors.primary,
                            ),
                            label: Text('Kota Saya ($userCity)'),
                            selected: isFilteredByMyCity,
                            selectedColor: AppColors.primary,
                            labelStyle: TextStyle(
                              color: isFilteredByMyCity ? Colors.white : AppColors.textPrimary,
                              fontWeight: isFilteredByMyCity ? FontWeight.bold : FontWeight.normal,
                              fontSize: 12,
                            ),
                            backgroundColor: Colors.grey[100],
                            onSelected: (_) {
                              itemsProvider.setCity(userCity);
                            },
                          ),
                          const SizedBox(width: 8),

                          // Dropdown untuk memilih kota lain
                          PopupMenuButton<String>(
                            tooltip: 'Pilih Kota Lain',
                            onSelected: (String city) {
                              itemsProvider.setCity(city);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                              decoration: BoxDecoration(
                                color: (!isAllCities && !isFilteredByMyCity)
                                    ? AppColors.primary
                                    : Colors.grey[100],
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: (!isAllCities && !isFilteredByMyCity)
                                      ? AppColors.primary
                                      : AppColors.border,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.tune,
                                    size: 14,
                                    color: (!isAllCities && !isFilteredByMyCity)
                                        ? Colors.white
                                        : AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    (!isAllCities && !isFilteredByMyCity)
                                        ? itemsProvider.selectedCity
                                        : 'Kota Lain',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: (!isAllCities && !isFilteredByMyCity)
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: (!isAllCities && !isFilteredByMyCity)
                                          ? Colors.white
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_drop_down,
                                    size: 16,
                                    color: (!isAllCities && !isFilteredByMyCity)
                                        ? Colors.white
                                        : AppColors.textSecondary,
                                  ),
                                ],
                              ),
                            ),
                            itemBuilder: (_) {
                              return IndonesianCities.list.map((String city) {
                                return PopupMenuItem<String>(
                                  value: city,
                                  child: Text(city),
                                );
                              }).toList();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Search Bar & Filter Transaksi Header
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
                child: Column(
                  children: [
                    // Search Input
                    TextField(
                      controller: _searchController,
                      onChanged: (val) => itemsProvider.setSearchQuery(val),
                      decoration: InputDecoration(
                        hintText: 'Cari barang bekas, barter, atau donasi...',
                        prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  itemsProvider.setSearchQuery('');
                                },
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Filter Mode Transaksi Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip(
                            label: 'Semua Mode',
                            isSelected: itemsProvider.selectedType == null,
                            color: AppColors.primary,
                            onTap: () => itemsProvider.setFilterType(null),
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            label: 'Jual Beli',
                            isSelected: itemsProvider.selectedType == ListingType.sell,
                            color: AppColors.sellColor,
                            onTap: () => itemsProvider.setFilterType(ListingType.sell),
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            label: 'Tukar / Barter',
                            isSelected: itemsProvider.selectedType == ListingType.swap,
                            color: AppColors.swapColor,
                            onTap: () => itemsProvider.setFilterType(ListingType.swap),
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            label: 'Donasi Gratis',
                            isSelected: itemsProvider.selectedType == ListingType.share,
                            color: AppColors.shareColor,
                            onTap: () => itemsProvider.setFilterType(ListingType.share),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Horizontal Categories
            SliverToBoxAdapter(
              child: Container(
                height: 44,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: AppCategories.items.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final cat = AppCategories.items[index];
                    final isSelected = itemsProvider.selectedCategory == cat;
                    return ChoiceChip(
                      label: Text(
                        cat,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected ? AppColors.primary : AppColors.border,
                        ),
                      ),
                      onSelected: (_) => itemsProvider.setCategory(cat),
                    );
                  },
                ),
              ),
            ),

            // Grid Items
            if (itemsProvider.isLoading)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              )
            else if (itemsProvider.items.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 56, color: Colors.grey[400]),
                        const SizedBox(height: 12),
                        Text(
                          isAllCities
                              ? 'Belum ada barang di kategori ini'
                              : 'Belum ada barang di "${itemsProvider.selectedCity}"',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isAllCities
                              ? 'Jadilah yang pertama memasang barang!'
                              : 'Coba ganti filter daerah ke Semua Kota atau jadilah yang pertama berbagi barang di kota Anda!',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                        ),
                        if (!isAllCities) ...[
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.public, size: 16),
                            label: const Text('Tampilkan Semua Kota'),
                            onPressed: () {
                              itemsProvider.setCity('Semua Kota');
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.68,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = itemsProvider.items[index];
                      return ItemCard(
                        item: item,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ItemDetailScreen(itemId: item.id),
                            ),
                          );
                        },
                      );
                    },
                    childCount: itemsProvider.items.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : color.withOpacity(0.2),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : color,
          ),
        ),
      ),
    );
  }
}
