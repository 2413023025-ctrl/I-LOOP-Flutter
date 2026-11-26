import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_categories.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/item_model.dart';
import '../../state/items_provider.dart';
import '../widgets/item_card.dart';
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
            // Search Bar & Filter Header
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
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
                    const SizedBox(height: 12),

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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 56, color: Colors.grey[400]),
                      const SizedBox(height: 12),
                      const Text(
                        'Belum ada barang di kategori ini',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Jadilah yang pertama memasang barang!',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                      ),
                    ],
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
