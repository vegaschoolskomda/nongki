import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/utils/app_utils.dart';
import '../../../providers/places_provider.dart';
import '../../../providers/favorites_provider.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/review_provider.dart';

class PlaceDetailScreen extends ConsumerWidget {
  final String placeId;

  const PlaceDetailScreen({super.key, required this.placeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final placeAsync = ref.watch(placeDetailProvider(placeId));
    final menuAsync = ref.watch(placeMenuProvider(placeId));
    final reviewsAsync = ref.watch(placeReviewsProvider(placeId));
    final favorites = ref.watch(favoritesProvider);
    final isFav = favorites.contains(placeId);

    return placeAsync.when(
      data: (place) {
        if (place == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const EmptyStateWidget(
              icon: Icons.storefront_outlined,
              title: 'Tempat tidak ditemukan',
              message: 'Tempat yang kamu cari mungkin sudah tidak tersedia.',
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            slivers: [
              // Hero Image App Bar
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                backgroundColor: AppColors.primary,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.white),
                    onPressed: () => context.pop(),
                  ),
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Badge(
                        isLabelVisible: ref.watch(cartProvider).isNotEmpty,
                        label: Text('${ref.watch(cartProvider).totalItemsCount}'),
                        backgroundColor: const Color(0xFFE67E22),
                        child: const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 20),
                      ),
                      onPressed: () => context.push('/cart'),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: isFav ? AppColors.error : Colors.white,
                        size: 20,
                      ),
                      onPressed: () {
                        ref.read(favoritesProvider.notifier).toggleFavorite(place.id);
                      },
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      place.imageUrl != null
                          ? CachedNetworkImage(
                              imageUrl: place.imageUrl!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(color: AppColors.accent),
                              errorWidget: (context, url, err) => Container(
                                color: AppColors.accent,
                                child: const Icon(Icons.image_not_supported, size: 48),
                              ),
                            )
                          : Container(color: AppColors.accent),
                      // Gradient overlay
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black38,
                              Colors.transparent,
                              Colors.black54,
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Content Body
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status & Category row
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: place.isOpen ? AppColors.success : AppColors.error,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              place.isOpen ? 'Buka Sekarang' : 'Tutup',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              place.category,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Name
                      Text(place.name, style: AppTextStyles.displayMedium.copyWith(fontSize: 24)),
                      const SizedBox(height: 8),

                      // Price range & Rating
                      Row(
                        children: [
                          Text(
                            place.priceRange,
                            style: AppTextStyles.price.copyWith(fontSize: 18),
                          ),
                          const Spacer(),
                          if (place.rating != null) ...[
                            const Icon(Icons.star_rounded, size: 22, color: AppColors.starActive),
                            const SizedBox(width: 4),
                            Text(
                              place.rating!.toStringAsFixed(1),
                              style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${place.reviewCount} ulasan)',
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 12),

                      // Location & Hours
                      if (place.address != null) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.location_on_outlined, size: 20, color: AppColors.primary),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    place.address!,
                                    style: AppTextStyles.bodyMedium,
                                  ),
                                  if (place.formattedDistance.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'Jarak: ${place.formattedDistance} dari posisimu',
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFFE67E22),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                context.push('/map/${Uri.encodeComponent(place.id)}');
                              },
                              icon: const Icon(Icons.map, size: 16),
                              label: const Text('Peta'),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (place.openingHours != null) ...[
                        Row(
                          children: [
                            const Icon(Icons.access_time_outlined, size: 20, color: AppColors.primary),
                            const SizedBox(width: 12),
                            Text(place.openingHours!, style: AppTextStyles.bodyMedium),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                      const Divider(),
                      const SizedBox(height: 16),

                      // Facilities
                      if (place.facilities.isNotEmpty) ...[
                        Text('Fasilitas Tempat', style: AppTextStyles.headingSmall),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: place.facilities.map((fac) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.check_circle_outline,
                                      size: 16, color: AppColors.success),
                                  const SizedBox(width: 6),
                                  Text(fac, style: AppTextStyles.bodySmall),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 16),
                      ],

                      // Description
                      if (place.description != null) ...[
                        Text('Tentang Tempat Ini', style: AppTextStyles.headingSmall),
                        const SizedBox(height: 8),
                        Text(
                          place.description!,
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 16),
                      ],

                      // Menu Preview Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Menu Andalan', style: AppTextStyles.headingSmall),
                          GestureDetector(
                            onTap: () => context.push('/place/${Uri.encodeComponent(place.id)}/menu'),
                            child: Text(
                              'Lihat Semua Menu',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      menuAsync.when(
                        data: (items) {
                          if (items.isEmpty) {
                            return const Text('Belum ada menu yang didaftarkan.',
                                style: AppTextStyles.caption);
                          }
                          final previewItems = items.take(3).toList();
                          return Column(
                            children: previewItems.map((item) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.border, width: 0.8),
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: SizedBox(
                                        width: 60,
                                        height: 60,
                                        child: item.imageUrl != null
                                            ? CachedNetworkImage(
                                                imageUrl: item.imageUrl!,
                                                fit: BoxFit.cover,
                                              )
                                            : Container(color: AppColors.accent),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(item.name,
                                              style: AppTextStyles.labelLarge
                                                  .copyWith(fontWeight: FontWeight.w600)),
                                          const SizedBox(height: 4),
                                          Text(
                                            AppUtils.formatCurrency(item.price),
                                            style: AppTextStyles.caption
                                                .copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    SizedBox(
                                      height: 32,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          padding: const EdgeInsets.symmetric(horizontal: 10),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                          elevation: 0,
                                        ),
                                        onPressed: () {
                                          final cartNotifier = ref.read(cartProvider.notifier);
                                          if (cartNotifier.isDifferentPlace(place.id)) {
                                            cartNotifier.addItem(item, place, forceReplace: true);
                                          } else {
                                            cartNotifier.addItem(item, place);
                                          }
                                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('${item.name} dimasukkan ke pesanan!'),
                                              duration: const Duration(seconds: 2),
                                              action: SnackBarAction(
                                                label: 'Lihat Keranjang',
                                                textColor: AppColors.accent,
                                                onPressed: () => context.push('/cart'),
                                              ),
                                            ),
                                          );
                                        },
                                        child: const Text(
                                          '+ Pesan',
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          );
                        },
                        loading: () => const Center(
                          child: CircularProgressIndicator(color: AppColors.primary),
                        ),
                        error: (err, stack) => const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 16),

                      // Customer Reviews Section
                      Text('Ulasan Pengunjung', style: AppTextStyles.headingSmall),
                      const SizedBox(height: 12),
                      reviewsAsync.when(
                        data: (revs) {
                          if (revs.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                'Belum ada ulasan untuk tempat ini. Jadilah yang pertama nongki di sini!',
                                style: AppTextStyles.caption,
                              ),
                            );
                          }
                          return Column(
                            children: revs.map((r) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.border, width: 0.6),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(r.userName,
                                            style: AppTextStyles.labelMedium
                                                .copyWith(fontWeight: FontWeight.w600)),
                                        Row(
                                          children: [
                                            const Icon(Icons.star_rounded,
                                                size: 16, color: AppColors.starActive),
                                            const SizedBox(width: 2),
                                            Text(
                                              r.rating.toStringAsFixed(1),
                                              style: AppTextStyles.caption
                                                  .copyWith(fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(r.comment, style: AppTextStyles.bodySmall),
                                    const SizedBox(height: 4),
                                    Text(
                                      AppUtils.formatDate(r.createdAt),
                                      style: AppTextStyles.caption.copyWith(fontSize: 10),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          );
                        },
                        loading: () => const Center(
                          child: CircularProgressIndicator(color: AppColors.primary),
                        ),
                        error: (err, stack) => const SizedBox.shrink(),
                      ),

                      // Space for bottom sticky bar
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomSheet: Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: CustomButton(
                text: 'Lihat Daftar Menu & Pesan',
                icon: Icons.restaurant_menu,
                onPressed: () {
                  context.push('/place/${Uri.encodeComponent(place.id)}/menu');
                },
              ),
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: BrandedLoadingWidget(message: 'Memuat informasi tempat...'),
      ),
      error: (err, stack) => Scaffold(
        appBar: AppBar(),
        body: EmptyStateWidget(
          icon: Icons.error_outline,
          title: 'Gagal memuat tempat',
          message: err.toString(),
        ),
      ),
    );
  }
}
