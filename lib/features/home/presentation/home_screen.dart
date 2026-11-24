import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/location_service.dart';
import '../../../data/models/place_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/places_provider.dart';
import '../../../providers/favorites_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final VoidCallback onNavigateToExplore;

  const HomeScreen({super.key, required this.onNavigateToExplore});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedBudgetIndex = 0; // Default '< Rp20rb'

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final placesAsync = ref.watch(placesListProvider);
    final nearestAsync = ref.watch(nearestPlacesProvider);
    final favorites = ref.watch(favoritesProvider);
    final locationAsync = ref.watch(userLocationProvider);
    final userLoc = locationAsync.valueOrNull ?? UserLocation.defaultLocation;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            ref.read(userLocationProvider.notifier).refreshLocation();
            ref.invalidate(placesListProvider);
            ref.invalidate(nearestPlacesProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (authState.isInPreviewMode) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.remove_red_eye_outlined, color: Colors.white, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Mode Pratinjau: ${authState.effectiveRole.toUpperCase()}',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            ref.read(authProvider.notifier).clearPreviewRole();
                            context.go('/admin');
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Kembali ke Admin',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: Color(0xFFF7EFE9),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // 1. BRAND LOGO DI TENGAH ATAS
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border.withValues(alpha: 0.6), width: 1),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0A000000),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/logo/logo.png',
                      height: 24,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Text(
                        AppConstants.appName,
                        style: AppTextStyles.headingMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 3,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 2. HEADER: Sapaan, Lokasi, dan Avatar Profil
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Sapaan & Lokasi Dropdown
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selamat pagi, ${authState.user?.name ?? 'Vega'}',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 2),
                        InkWell(
                          onTap: () => context.push('/map'),
                          child: Row(
                            children: [
                              Icon(
                                userLoc.isLive ? Icons.my_location : Icons.location_on_outlined,
                                size: 18,
                                color: userLoc.isLive ? Colors.blue.shade700 : AppColors.textPrimary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                userLoc.districtName,
                                style: AppTextStyles.labelLarge.copyWith(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 2),
                              const Icon(
                                Icons.keyboard_arrow_down,
                                size: 18,
                                color: AppColors.textPrimary,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Avatar Bulat dengan Badge Oranye
                    GestureDetector(
                      onTap: () => context.push('/profile-tab'),
                      child: Stack(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(
                              color: AppColors.primaryDark,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Text(
                                'VA',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          // Dot Oranye Online
                          Positioned(
                            top: 1,
                            right: 1,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE67E22),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // 3. SEARCH BAR
                InkWell(
                  onTap: widget.onNavigateToExplore,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border, width: 0.9),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.cardShadow,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: AppColors.textSecondary, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Cari kafe, menu, atau suasana...',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const Icon(Icons.tune, color: AppColors.textSecondary, size: 20),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 4. SECTION: REKOMENDASI UNTUKMU
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Rekomendasi untukmu',
                      style: AppTextStyles.headingSmall.copyWith(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.onNavigateToExplore,
                      child: const Text(
                        'Lihat semua',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFE67E22),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // HERO FEATURED CARD (Nearest / Recommended from CSV)
                _buildHeroFeaturedCard(
                  context,
                  nearestAsync.valueOrNull?.isNotEmpty == true
                      ? nearestAsync.valueOrNull!.first
                      : (placesAsync.valueOrNull?.isNotEmpty == true
                          ? placesAsync.valueOrNull!.first
                          : null),
                ),
                const SizedBox(height: 18),

                // 5. FEATURE SHORTCUTS GRID (Exhibition Edition)
                Row(
                  children: [
                    Expanded(
                      child: _buildFeatureCard(
                        icon: Icons.casino_outlined,
                        title: 'Nongki Roulette',
                        subtitle: 'Putar acak kafe',
                        badge: 'BARU',
                        onTap: () => context.push('/roulette'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildFeatureCard(
                        icon: Icons.swipe_rounded,
                        title: 'Swipe & Discover',
                        subtitle: 'Jelajah kartu kafe',
                        badge: 'BARU',
                        onTap: () => context.push('/swipe'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildFeatureCard(
                        icon: Icons.stars_rounded,
                        title: 'Nongki Points',
                        subtitle: 'Hadiah & voucher',
                        badge: 'LOYALTI',
                        onTap: () => context.push('/points'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildFeatureCard(
                        icon: Icons.map_outlined,
                        title: 'Peta Sekitarmu',
                        subtitle: 'Navigasi kafe terdekat',
                        badge: 'PETA',
                        onTap: () => context.push('/map'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 26),

                // 6. SECTION: NONGKI SESUAI BUDGET
                const Text(
                  'PILIHAN UNTUKMU',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: Color(0xFFE67E22),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Nongki sesuai budget',
                      style: AppTextStyles.headingSmall.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.onNavigateToExplore,
                      child: const Row(
                        children: [
                          Text(
                            'Lihat semua',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Icon(Icons.chevron_right, size: 16, color: AppColors.textSecondary),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Budget Filter Chips: < Rp20rb | Rp20-35rb | Rp35-50rb
                Row(
                  children: List.generate(AppConstants.budgetRanges.length, (index) {
                    final b = AppConstants.budgetRanges[index];
                    final isSelected = _selectedBudgetIndex == index;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedBudgetIndex = index;
                          });
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primaryDark : AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? AppColors.primaryDark : AppColors.border,
                            ),
                          ),
                          child: Text(
                            b['label'] as String,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),

                // Horizontal Place Cards: "Ruang Temu Coffee", "Sudut Senja Coffee"
                placesAsync.when(
                  data: (places) {
                    // Filter sesuai budget yang dipilih
                    final currentRange = AppConstants.budgetRanges[_selectedBudgetIndex];
                    final maxBudget = currentRange['max'] as int;

                    // Urutkan atau ambil tempat yang relevan
                    final filtered = places.where((p) => p.priceMin <= maxBudget).toList();
                    final displayPlaces = filtered.isNotEmpty ? filtered : places;

                    return SizedBox(
                      height: 245,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: displayPlaces.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 14),
                        itemBuilder: (context, index) {
                          final place = displayPlaces[index];
                          final isFav = favorites.contains(place.id);

                          return _buildHorizontalPlaceCard(
                            context: context,
                            place: place,
                            isFavorite: isFav,
                            onTap: () => context.push('/place/${Uri.encodeComponent(place.id)}'),
                            onFavoriteTap: () {
                              ref.read(favoritesProvider.notifier).toggleFavorite(place.id);
                            },
                          );
                        },
                      ),
                    );
                  },
                  loading: () => const SizedBox(
                    height: 245,
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  ),
                  error: (e, _) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 26),

                // 7. SECTION: PROMO HARI INI
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Promo hari ini',
                      style: AppTextStyles.headingSmall.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.onNavigateToExplore,
                      child: const Row(
                        children: [
                          Text(
                            'Lihat semua',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Icon(Icons.chevron_right, size: 16, color: AppColors.textSecondary),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // PROMO CARD BANNER (Diskon 20% kopi kedua di Ruang Temu Coffee)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDE7CC), // Warm peach cream seperti foto
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0F000000),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Promo text info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'HANYA HARI INI',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.6,
                                color: AppColors.primaryDark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Diskon 20% kopi kedua',
                              style: AppTextStyles.labelLarge.copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'di Ruang Temu Coffee',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Big 20% Text
                      const Text(
                        '20%',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFC47A3A), // Warm bronze / amber
                          letterSpacing: -1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // WIDGET: HERO FEATURED CARD (Dynamic from CSV / Location)
  Widget _buildHeroFeaturedCard(BuildContext context, PlaceModel? place) {
    final title = place?.name ?? 'Es Coklat Impian';
    final ratingStr = place?.rating?.toStringAsFixed(1) ?? '4.7';
    final reviewCountStr = place != null ? '(${place.reviewCount})' : '(120)';
    final addressStr = place != null
        ? (place.formattedDistance.isNotEmpty
            ? '${place.kecamatan ?? 'Sidoarjo'} • ${place.formattedDistance}'
            : (place.address ?? 'Sidoarjo'))
        : 'Kavling DPR, Sidoarjo';
    final imageUrl = place?.imageUrl ??
        'https://images.unsplash.com/photo-1554118811-1e0d58224f24?auto=format&fit=crop&w=800&q=80';

    return GestureDetector(
      onTap: () {
        if (place != null) {
          context.push('/place/${Uri.encodeComponent(place.id)}');
        }
      },
      child: Container(
        height: 195,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1F000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background Image
              CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: AppColors.accent),
                errorWidget: (context, url, err) => Container(color: AppColors.accent),
              ),

              // Gradient Overlay
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Color(0x40000000),
                      Color(0xCC1A0C06),
                    ],
                  ),
                ),
              ),

              // Content at Bottom
              Positioned(
                left: 16,
                right: 16,
                bottom: 14,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Rating Pill
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.45),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star_rounded, size: 14, color: AppColors.starActive),
                                const SizedBox(width: 3),
                                Text(
                                  '$ratingStr $reviewCountStr',
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Title
                          Text(
                            title,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),

                          // Address
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, size: 13, color: Colors.white70),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  addressStr,
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 11,
                                    color: Colors.white70,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Button "Lihat Detail"
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primaryDark,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                        minimumSize: Size.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {
                        if (place != null) {
                          context.push('/place/${Uri.encodeComponent(place.id)}');
                        }
                      },
                      child: const Text(
                        'Lihat Detail',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // WIDGET: SHORTCUT CARD (Exhibition Edition)
  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    String? badge,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 0.8),
          boxShadow: const [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Icon Container
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7EFE9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 18, color: AppColors.primary),
                ),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE67E22),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: AppTextStyles.labelMedium.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 12,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: AppTextStyles.caption.copyWith(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // WIDGET: HORIZONTAL PLACE CARD (Ruang Temu Coffee & Sudut Senja)
  Widget _buildHorizontalPlaceCard({
    required BuildContext context,
    required PlaceModel place,
    required bool isFavorite,
    required VoidCallback onTap,
    required VoidCallback onFavoriteTap,
  }) {
    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.8),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Image with Favorite Button
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: SizedBox(
                    height: 125,
                    width: double.infinity,
                    child: place.imageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: place.imageUrl!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(color: AppColors.accent),
                            errorWidget: (context, url, err) => Container(color: AppColors.accent),
                          )
                        : Container(color: AppColors.accent),
                  ),
                ),
                // Heart favorite button
                Positioned(
                  top: 8,
                  right: 8,
                  child: InkWell(
                    onTap: onFavoriteTap,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 4),
                        ],
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        size: 18,
                        color: isFavorite ? AppColors.error : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Bottom Content
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          place.name,
                          style: AppTextStyles.labelLarge.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (place.rating != null) ...[
                        const Icon(Icons.star_rounded, size: 16, color: AppColors.starActive),
                        const SizedBox(width: 2),
                        Text(
                          place.rating!.toStringAsFixed(1),
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),

                  // Location & Distance
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 13, color: AppColors.textSecondary),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          place.formattedDistance.isNotEmpty
                              ? '${place.kecamatan ?? 'Sidoarjo'} • ${place.formattedDistance}'
                              : (place.address ?? 'Sidoarjo'),
                          style: AppTextStyles.caption.copyWith(fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Facilities tags (Wi-Fi, Stopkontak, Outdoor)
                  Wrap(
                    spacing: 6,
                    children: place.facilities.take(2).map((fac) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7EFE9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          fac,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
