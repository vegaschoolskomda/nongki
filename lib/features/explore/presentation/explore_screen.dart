import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/place_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../providers/places_provider.dart';
import '../../../providers/favorites_provider.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showSortModal() {
    final currentSort = ref.read(placeFilterProvider).sortBy;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Urutkan Berdasarkan',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildSortOption(
                  title: 'Rekomendasi Terbaik',
                  selected: currentSort == 'recommended',
                  onTap: () {
                    ref.read(placeFilterProvider.notifier).setSortBy('recommended');
                    Navigator.pop(context);
                  },
                ),
                _buildSortOption(
                  title: 'Jarak Terdekat (GPS)',
                  selected: currentSort == 'nearest',
                  onTap: () {
                    ref.read(placeFilterProvider.notifier).setSortBy('nearest');
                    Navigator.pop(context);
                  },
                ),
                _buildSortOption(
                  title: 'Rating Tertinggi',
                  selected: currentSort == 'rating',
                  onTap: () {
                    ref.read(placeFilterProvider.notifier).setSortBy('rating');
                    Navigator.pop(context);
                  },
                ),
                _buildSortOption(
                  title: 'Harga Terendah',
                  selected: currentSort == 'price_asc',
                  onTap: () {
                    ref.read(placeFilterProvider.notifier).setSortBy('price_asc');
                    Navigator.pop(context);
                  },
                ),
                _buildSortOption(
                  title: 'Harga Tertinggi',
                  selected: currentSort == 'price_desc',
                  onTap: () {
                    ref.read(placeFilterProvider.notifier).setSortBy('price_desc');
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSortOption({
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected ? AppColors.primary : AppColors.textPrimary,
        ),
      ),
      trailing: selected
          ? const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20)
          : null,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final filterState = ref.watch(placeFilterProvider);
    final placesAsync = ref.watch(placesListProvider);
    final favorites = ref.watch(favoritesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Jelajah Tempat'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
            ),
            child: IconButton(
              icon: const Icon(Icons.tune_rounded, size: 20, color: AppColors.primary),
              tooltip: 'Urutkan',
              onPressed: _showSortModal,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Search & Filter header ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
            child: Column(
              children: [
                // Search Input Field
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border.withValues(alpha: 0.8), width: 0.8),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x06000000),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      ref.read(placeFilterProvider.notifier).setQuery(val);
                    },
                    decoration: InputDecoration(
                      hintText: 'Cari tempat, kafe, atau menu...',
                      hintStyle: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                      prefixIcon: const Icon(Icons.search_rounded,
                          color: AppColors.textSecondary, size: 22),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                ref.read(placeFilterProvider.notifier).setQuery('');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Category Chips
                SizedBox(
                  height: 38,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: AppConstants.placeCategories.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final cat = AppConstants.placeCategories[index];
                      final isSelected = filterState.category == cat;

                      return FilterChip(
                        label: Text(cat),
                        selected: isSelected,
                        labelStyle: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                        ),
                        backgroundColor: AppColors.surface,
                        selectedColor: AppColors.primary,
                        showCheckmark: false,
                        side: BorderSide(
                          color: isSelected ? AppColors.primary : AppColors.border,
                          width: 0.8,
                        ),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        onSelected: (selected) {
                          ref.read(placeFilterProvider.notifier).setCategory(cat);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // ── Active filter indicator & Result count ──────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                placesAsync.maybeWhen(
                  data: (places) => Text(
                    'Menampilkan ${places.length} kafe',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  orElse: () => const Text('Memuat tempat...',
                      style: AppTextStyles.caption),
                ),
                if (filterState.hasActiveFilter)
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      ref.read(placeFilterProvider.notifier).resetFilters();
                    },
                    child: const Text(
                      'Reset Filter',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── Places List ─────────────────────────────────────────────
          Expanded(
            child: placesAsync.when(
              data: (places) {
                if (places.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.search_off_rounded,
                    title: 'Tidak ada tempat ditemukan',
                    message:
                        'Coba cari dengan kata kunci lain atau pilih kategori yang berbeda.',
                    buttonText: 'Hapus Filter',
                    onButtonPressed: () {
                      _searchController.clear();
                      ref.read(placeFilterProvider.notifier).resetFilters();
                    },
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
                  itemCount: places.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final place = places[index];
                    final isFav = favorites.contains(place.id);

                    return PlaceCard(
                      place: place,
                      isFavorite: isFav,
                      onTap: () {
                        context.push('/place/${Uri.encodeComponent(place.id)}');
                      },
                      onFavoriteTap: () {
                        ref.read(favoritesProvider.notifier).toggleFavorite(place.id);
                      },
                    );
                  },
                );
              },
              loading: () =>
                  const BrandedLoadingWidget(message: 'Mencari tempat nongki seru...'),
              error: (err, stack) => EmptyStateWidget(
                icon: Icons.error_outline_rounded,
                title: 'Gagal memuat tempat',
                message: 'Silakan periksa koneksi atau coba kembali.',
                buttonText: 'Muat Ulang',
                onButtonPressed: () => ref.invalidate(placesListProvider),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/map'),
        backgroundColor: AppColors.primary,
        elevation: 4,
        icon: const Icon(Icons.map_rounded, color: Colors.white, size: 20),
        label: const Text(
          'Lihat Peta',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
