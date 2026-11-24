import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../data/models/place_model.dart';
import '../../../providers/places_provider.dart';
import '../../../providers/favorites_provider.dart';

class SwipeDiscoverScreen extends ConsumerStatefulWidget {
  const SwipeDiscoverScreen({super.key});

  @override
  ConsumerState<SwipeDiscoverScreen> createState() => _SwipeDiscoverScreenState();
}

class _SwipeDiscoverScreenState extends ConsumerState<SwipeDiscoverScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  Offset _dragOffset = Offset.zero;
  double _dragAngle = 0.0;

  void _onSwipeLeft(PlaceModel place) {
    setState(() {
      _currentIndex++;
      _dragOffset = Offset.zero;
      _dragAngle = 0.0;
    });
  }

  void _onSwipeRight(PlaceModel place) {
    ref.read(favoritesProvider.notifier).toggleFavorite(place.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.favorite, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text('${place.name} ditambahkan ke Favorit!')),
          ],
        ),
        backgroundColor: const Color(0xFF27AE60),
        duration: const Duration(seconds: 1),
      ),
    );
    setState(() {
      _currentIndex++;
      _dragOffset = Offset.zero;
      _dragAngle = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final placesAsync = ref.watch(placesListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Swipe & Discover'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_rounded, color: Color(0xFFE74C3C)),
            tooltip: 'Lihat Favorit',
            onPressed: () => context.push('/favorites-tab'),
          ),
        ],
      ),
      body: placesAsync.when(
        data: (places) {
          if (places.isEmpty) {
            return const Center(child: Text('Data kafe belum tersedia.'));
          }

          if (_currentIndex >= places.length) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_outline_rounded,
                        size: 48,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Semua Kafe Telah Dilihat!',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Kamu sudah menjelajahi semua rekomendasi kafe. Ingin mengulangi eksplorasi dari awal?',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                      onPressed: () {
                        setState(() {
                          _currentIndex = 0;
                        });
                      },
                      icon: const Icon(Icons.replay_rounded, size: 18),
                      label: const Text(
                        'Ulangi dari Awal',
                        style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final currentPlace = places[_currentIndex];
          final nextPlace = _currentIndex + 1 < places.length ? places[_currentIndex + 1] : null;

          return SafeArea(
            child: Column(
              children: [
                // Instruction hint
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.swipe_left_rounded, size: 16, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        'Geser kiri: Lewati',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text('•', style: TextStyle(color: Colors.grey)),
                      const SizedBox(width: 16),
                      Text(
                        'Geser kanan: Suka',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.swipe_right_rounded, size: 16, color: Colors.grey.shade500),
                    ],
                  ),
                ),

                // Card Swiper Stack
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Next card behind (if exists)
                        if (nextPlace != null)
                          Transform.scale(
                            scale: 0.94,
                            child: _buildSwipeCard(nextPlace, isBackground: true),
                          ),

                        // Current active card with Drag Gesture
                        GestureDetector(
                          onPanUpdate: (details) {
                            setState(() {
                              _dragOffset += details.delta;
                              _dragAngle = (_dragOffset.dx / 300) * (math.pi / 10);
                            });
                          },
                          onPanEnd: (details) {
                            if (_dragOffset.dx > 120) {
                              _onSwipeRight(currentPlace);
                            } else if (_dragOffset.dx < -120) {
                              _onSwipeLeft(currentPlace);
                            } else {
                              // Snap back to center
                              setState(() {
                                _dragOffset = Offset.zero;
                                _dragAngle = 0.0;
                              });
                            }
                          },
                          child: Transform.translate(
                            offset: _dragOffset,
                            child: Transform.rotate(
                              angle: _dragAngle,
                              child: Stack(
                                children: [
                                  _buildSwipeCard(currentPlace, isBackground: false),

                                  // LIKE Stamp indicator on drag right
                                  if (_dragOffset.dx > 40)
                                    Positioned(
                                      top: 24,
                                      right: 24,
                                      child: Transform.rotate(
                                        angle: 0.2,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: const Color(0xFF27AE60), width: 3),
                                            borderRadius: BorderRadius.circular(10),
                                            color: Colors.white.withValues(alpha: 0.8),
                                          ),
                                          child: const Text(
                                            'SUKA',
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 20,
                                              fontWeight: FontWeight.w900,
                                              color: Color(0xFF27AE60),
                                              letterSpacing: 2.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                  // NOPE Stamp indicator on drag left
                                  if (_dragOffset.dx < -40)
                                    Positioned(
                                      top: 24,
                                      left: 24,
                                      child: Transform.rotate(
                                        angle: -0.2,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: const Color(0xFFC0392B), width: 3),
                                            borderRadius: BorderRadius.circular(10),
                                            color: Colors.white.withValues(alpha: 0.8),
                                          ),
                                          child: const Text(
                                            'LEWATI',
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 20,
                                              fontWeight: FontWeight.w900,
                                              color: Color(0xFFC0392B),
                                              letterSpacing: 2.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Action Buttons: Pass (X), Detail (Eye), Like (Heart)
                Padding(
                  padding: const EdgeInsets.fromLTRB(36, 4, 36, 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Dislike / Pass Button
                      _buildCircleActionButton(
                        icon: Icons.close_rounded,
                        color: const Color(0xFFC0392B),
                        size: 54,
                        iconSize: 26,
                        onTap: () => _onSwipeLeft(currentPlace),
                      ),

                      // Detail Button
                      _buildCircleActionButton(
                        icon: Icons.info_outline_rounded,
                        color: AppColors.primary,
                        size: 48,
                        iconSize: 22,
                        onTap: () {
                          context.push('/place/${Uri.encodeComponent(currentPlace.id)}');
                        },
                      ),

                      // Like / Favorite Button
                      _buildCircleActionButton(
                        icon: Icons.favorite_rounded,
                        color: const Color(0xFF27AE60),
                        size: 54,
                        iconSize: 26,
                        onTap: () => _onSwipeRight(currentPlace),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const BrandedLoadingWidget(message: 'Menyiapkan kartu kafe...'),
        error: (e, _) => Center(child: Text(e.toString())),
      ),
    );
  }

  Widget _buildSwipeCard(PlaceModel place, {required bool isBackground}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.8), width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Cafe Image
            Expanded(
              flex: 6,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  place.imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: place.imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (c, u) => Container(color: AppColors.accent),
                          errorWidget: (c, u, e) => Container(
                            color: AppColors.accent,
                            child: const Icon(Icons.coffee, size: 48, color: AppColors.primary),
                          ),
                        )
                      : Container(
                          color: AppColors.accent,
                          child: const Icon(Icons.coffee, size: 48, color: AppColors.primary),
                        ),

                  // Category tag
                  Positioned(
                    top: 14,
                    left: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        place.category,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  // Open status
                  Positioned(
                    top: 14,
                    right: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: place.isOpen ? const Color(0xFF27AE60) : const Color(0xFFC0392B),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        place.isOpen ? 'Buka' : 'Tutup',
                        style: const TextStyle(
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
            ),

            // Bottom Information section
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name & Rating
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                place.name,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (place.rating != null) ...[
                              const Icon(Icons.star_rounded, size: 18, color: Color(0xFFF39C12)),
                              const SizedBox(width: 3),
                              Text(
                                place.rating!.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),

                        // Location
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                place.address ?? (place.kecamatan ?? 'Sidoarjo'),
                                style: AppTextStyles.caption.copyWith(fontSize: 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Price & Distance row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFDF6F0),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
                          ),
                          child: Text(
                            place.priceRange,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        if (place.formattedDistance.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              place.formattedDistance,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleActionButton({
    required IconData icon,
    required Color color,
    required double size,
    required double iconSize,
    required VoidCallback onTap,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(size / 2),
          child: Center(
            child: Icon(icon, color: color, size: iconSize),
          ),
        ),
      ),
    );
  }
}
