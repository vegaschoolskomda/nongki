import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../data/models/place_model.dart';
import '../../../providers/places_provider.dart';

class RouletteScreen extends ConsumerStatefulWidget {
  const RouletteScreen({super.key});

  @override
  ConsumerState<RouletteScreen> createState() => _RouletteScreenState();
}

class _RouletteScreenState extends ConsumerState<RouletteScreen>
    with SingleTickerProviderStateMixin {
  int _selectedBudgetIndex = 0; // 0 = Semua
  String _selectedCategory = 'Semua';
  String _selectedLocation = 'Semua';

  final List<String> _districts = [
    'Semua',
    'Sidoarjo',
    'Buduran',
    'Candi',
    'Waru',
    'Gedangan',
    'Taman',
    'Sukodono',
    'Krian',
    'Sedati',
    'Wonoayu',
  ];

  late AnimationController _spinController;
  late Animation<double> _spinAnimation;
  PlaceModel? _resultPlace;
  bool _isSpinning = false;
  double _currentAngle = 0.0;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );

    _spinAnimation = CurvedAnimation(
      parent: _spinController,
      curve: Curves.easeOutCubic,
    );

    _spinController.addListener(() {
      setState(() {
        _currentAngle = _spinAnimation.value * 12 * math.pi;
      });
    });

    _spinController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isSpinning = false;
        });
        if (_resultPlace != null) {
          _showResultModal(_resultPlace!);
        }
      }
    });
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  void _spinRoulette(List<PlaceModel> allPlaces) {
    if (_isSpinning) return;

    // Filter places based on user selection
    List<PlaceModel> filtered = List.from(allPlaces);

    // 1. Budget filter
    if (_selectedBudgetIndex > 0) {
      final range = AppConstants.budgetRanges[_selectedBudgetIndex - 1];
      final maxBudget = range['max'] as int;
      filtered = filtered.where((p) => p.priceMin <= maxBudget).toList();
    }

    // 2. Category filter
    if (_selectedCategory != 'Semua') {
      filtered = filtered.where((p) => p.category.toLowerCase().contains(_selectedCategory.toLowerCase())).toList();
    }

    // 3. Location filter
    if (_selectedLocation != 'Semua') {
      filtered = filtered.where((p) {
        final kec = p.kecamatan?.toLowerCase() ?? '';
        final addr = p.address?.toLowerCase() ?? '';
        final loc = _selectedLocation.toLowerCase();
        return kec.contains(loc) || addr.contains(loc);
      }).toList();
    }

    if (filtered.isEmpty) {
      // Fallback if no matching place exists
      filtered = allPlaces;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak ada kafe yang tepat sesuai filter spesifik, mengacak dari seluruh kafe tersedia.'),
          duration: Duration(seconds: 2),
        ),
      );
    }

    // Pick a random place
    final random = math.Random();
    final picked = filtered[random.nextInt(filtered.length)];

    setState(() {
      _resultPlace = picked;
      _isSpinning = true;
    });

    _spinController.reset();
    _spinController.forward();
  }

  void _showResultModal(PlaceModel place) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7EFE9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome, color: Color(0xFFE67E22), size: 16),
                    SizedBox(width: 6),
                    Text(
                      'Rekomendasi Terpilih Untukmu!',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Image Card
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  height: 160,
                  width: double.infinity,
                  child: place.imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: place.imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (c, u) => Container(color: AppColors.accent),
                          errorWidget: (c, u, e) => Container(
                            color: AppColors.accent,
                            child: const Icon(Icons.coffee, size: 40, color: AppColors.primary),
                          ),
                        )
                      : Container(
                          color: AppColors.accent,
                          child: const Icon(Icons.coffee, size: 40, color: AppColors.primary),
                        ),
                ),
              ),
              const SizedBox(height: 14),

              // Title & Category
              Text(
                place.name,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),

              // Location
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      place.address ?? (place.kecamatan ?? 'Sidoarjo'),
                      style: AppTextStyles.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Price & Rating
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      place.priceRange,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
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
                    const SizedBox(width: 3),
                    Text('(${place.reviewCount})', style: AppTextStyles.caption),
                  ],
                ],
              ),
              const SizedBox(height: 24),

              // Buttons: "Lihat Detail" & "Coba Lagi"
              CustomButton(
                text: 'Lihat Detail Kafe',
                icon: Icons.storefront_rounded,
                onPressed: () {
                  Navigator.pop(ctx);
                  context.push('/place/${Uri.encodeComponent(place.id)}');
                },
              ),
              const SizedBox(height: 10),
              CustomButton(
                text: 'Putar Lagi',
                type: ButtonType.outlined,
                icon: Icons.refresh_rounded,
                onPressed: () {
                  Navigator.pop(ctx);
                  final places = ref.read(placesListProvider).valueOrNull ?? [];
                  if (places.isNotEmpty) {
                    _spinRoulette(places);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final placesAsync = ref.watch(placesListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Nongki Roulette'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: placesAsync.when(
        data: (places) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header intro
                Center(
                  child: Column(
                    children: [
                      const Text(
                        'Bingung Mau Nongki di Mana?',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tentukan kriteriamu dan biarkan NONGKI memilihkan tempat asik untukmu!',
                        style: AppTextStyles.caption.copyWith(fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── Animated Roulette Wheel ──────────────────────────────
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer glow ring
                      Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.accent.withValues(alpha: 0.35),
                        ),
                      ),

                      // Rotating Wheel
                      Transform.rotate(
                        angle: _currentAngle,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const SweepGradient(
                              colors: [
                                Color(0xFF5B3023),
                                Color(0xFF986747),
                                Color(0xFFD4A373),
                                Color(0xFF5B3023),
                                Color(0xFF3D211A),
                                Color(0xFF986747),
                                Color(0xFF5B3023),
                              ],
                            ),
                            border: Border.all(color: Colors.white, width: 4),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x22000000),
                                blurRadius: 14,
                                offset: Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: List.generate(8, (i) {
                              final rad = (i * 45) * math.pi / 180;
                              return Positioned(
                                left: 90 + 65 * math.cos(rad),
                                top: 90 + 65 * math.sin(rad),
                                child: Transform.rotate(
                                  angle: rad + math.pi / 2,
                                  child: const Icon(
                                    Icons.coffee_rounded,
                                    color: Colors.white70,
                                    size: 18,
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),

                      // Center Hub Button
                      GestureDetector(
                        onTap: () => _spinRoulette(places),
                        child: Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFE67E22), width: 3),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 8,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              _isSpinning ? '...' : 'PUTAR',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primary,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Top Indicator Arrow Pointer
                      Positioned(
                        top: 0,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE67E22),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Filter Section 1: Budget ─────────────────────────────
                const Text(
                  '1. Budget Kamu',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildChip(
                        label: 'Semua Budget',
                        selected: _selectedBudgetIndex == 0,
                        onTap: () => setState(() => _selectedBudgetIndex = 0),
                      ),
                      ...List.generate(AppConstants.budgetRanges.length, (idx) {
                        final b = AppConstants.budgetRanges[idx];
                        return Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: _buildChip(
                            label: b['label'] as String,
                            selected: _selectedBudgetIndex == idx + 1,
                            onTap: () => setState(() => _selectedBudgetIndex = idx + 1),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Filter Section 2: Kategori ───────────────────────────
                const Text(
                  '2. Kategori Tempat',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: AppConstants.placeCategories.map((cat) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _buildChip(
                          label: cat,
                          selected: _selectedCategory == cat,
                          onTap: () => setState(() => _selectedCategory = cat),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Filter Section 3: Wilayah / Kecamatan ────────────────
                const Text(
                  '3. Wilayah Lokasi',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedLocation,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
                      items: _districts.map((d) {
                        return DropdownMenuItem<String>(
                          value: d,
                          child: Text(
                            d == 'Semua' ? 'Semua Wilayah (Sidoarjo & Sekitar)' : 'Kecamatan $d',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedLocation = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // ── Tombol Putar Rekomendasi ─────────────────────────────
                CustomButton(
                  text: _isSpinning ? 'Sedang Mengacak Kafe...' : 'Putar Rekomendasi Sekarang',
                  icon: Icons.casino_outlined,
                  isLoading: _isSpinning,
                  onPressed: () => _spinRoulette(places),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
        loading: () => const BrandedLoadingWidget(message: 'Menyiapkan data kafe untuk roulette...'),
        error: (e, _) => Center(child: Text(e.toString())),
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: 0.9,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
