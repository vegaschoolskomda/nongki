import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/location_service.dart';
import '../../../data/models/place_model.dart';
import '../../../providers/places_provider.dart';

class MapScreen extends ConsumerStatefulWidget {
  final String? initialPlaceId;

  const MapScreen({super.key, this.initialPlaceId});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final MapController _mapController = MapController();
  PlaceModel? _selectedPlace;

  @override
  Widget build(BuildContext context) {
    final locationAsync = ref.watch(userLocationProvider);
    final placesAsync = ref.watch(placesListProvider);

    final userLoc = locationAsync.valueOrNull ?? UserLocation.defaultLocation;
    final userLatLng = LatLng(userLoc.latitude, userLoc.longitude);

    return Scaffold(
      body: Stack(
        children: [
          // ── OpenStreetMap Layer ──────────────────────────────────────────
          placesAsync.when(
            data: (places) {
              // Auto select initial place if provided
              if (widget.initialPlaceId != null && _selectedPlace == null) {
                final match = places.where((p) => p.id == widget.initialPlaceId);
                if (match.isNotEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() => _selectedPlace = match.first);
                      if (match.first.latitude != null && match.first.longitude != null) {
                        _mapController.move(
                          LatLng(match.first.latitude!, match.first.longitude!),
                          16.0,
                        );
                      }
                    }
                  });
                }
              }

              // Build Markers for Coffee Shops + User Location
              final markers = <Marker>[];

              // 1. User Location Pulse Marker
              markers.add(
                Marker(
                  point: userLatLng,
                  width: 60,
                  height: 60,
                  child: _UserLocationMarker(isLive: userLoc.isLive),
                ),
              );

              // 2. Coffee Shop Markers (filter shops that have valid lat/lng)
              for (final place in places) {
                if (place.latitude == null || place.longitude == null) continue;
                final isSelected = _selectedPlace?.id == place.id;
                final point = LatLng(place.latitude!, place.longitude!);

                markers.add(
                  Marker(
                    point: point,
                    width: isSelected ? 48 : 38,
                    height: isSelected ? 48 : 38,
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedPlace = place);
                        _mapController.move(point, 16.0);
                      },
                      child: _CafeMarker(
                        isSelected: isSelected,
                        rating: place.rating,
                      ),
                    ),
                  ),
                );
              }

              return FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _selectedPlace != null &&
                          _selectedPlace!.latitude != null &&
                          _selectedPlace!.longitude != null
                      ? LatLng(_selectedPlace!.latitude!, _selectedPlace!.longitude!)
                      : userLatLng,
                  initialZoom: 14.5,
                  minZoom: 10.0,
                  maxZoom: 18.0,
                  onTap: (tapPosition, point) {
                    if (_selectedPlace != null) {
                      setState(() => _selectedPlace = null);
                    }
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.nongki',
                  ),
                  MarkerLayer(markers: markers),
                ],
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
            error: (err, _) => Center(
              child: Text('Gagal memuat peta: $err'),
            ),
          ),

          // ── Top Navigation & GPS Status Bar ──────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  // Back Button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppColors.primaryDark),
                      onPressed: () => context.pop(),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Location Info Pill
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            userLoc.isLive ? Icons.my_location : Icons.location_on,
                            size: 18,
                            color: userLoc.isLive ? Colors.blue : AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  userLoc.isLive ? 'Lokasi Kamu' : 'Lokasi Default',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  userLoc.districtName,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              ref.read(userLocationProvider.notifier).refreshLocation();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Memperbarui koordinat GPS...'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(4),
                              child: Icon(Icons.refresh, size: 18, color: AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Floating Action Buttons (Re-center & Zoom) ───────────────────
          Positioned(
            right: 16,
            bottom: _selectedPlace != null ? 220 : 30,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Zoom In
                _MapActionButton(
                  icon: Icons.add,
                  onTap: () {
                    final zoom = _mapController.camera.zoom + 1;
                    _mapController.move(_mapController.camera.center, zoom);
                  },
                ),
                const SizedBox(height: 8),
                // Zoom Out
                _MapActionButton(
                  icon: Icons.remove,
                  onTap: () {
                    final zoom = _mapController.camera.zoom - 1;
                    _mapController.move(_mapController.camera.center, zoom);
                  },
                ),
                const SizedBox(height: 12),
                // Re-center on User Location
                _MapActionButton(
                  icon: Icons.gps_fixed,
                  iconColor: Colors.blue.shade700,
                  onTap: () {
                    _mapController.move(userLatLng, 15.5);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Pusatkan ke ${userLoc.districtName}'),
                        duration: const Duration(milliseconds: 800),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // ── Selected Place Bottom Card ───────────────────────────────────
          if (_selectedPlace != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 24,
              child: _PlacePreviewCard(
                place: _selectedPlace!,
                onClose: () => setState(() => _selectedPlace = null),
                onDetail: () => context.push('/place/${Uri.encodeComponent(_selectedPlace!.id)}'),
                onNavigate: () {
                  if (_selectedPlace!.latitude != null && _selectedPlace!.longitude != null) {
                    LocationService.openGoogleMapsRoute(
                      destLat: _selectedPlace!.latitude!,
                      destLng: _selectedPlace!.longitude!,
                      placeName: _selectedPlace!.name,
                    );
                  }
                },
              ),
            ),
        ],
      ),
    );
  }
}

// ─── User GPS Pulse Marker ────────────────────────────────────────────────────
class _UserLocationMarker extends StatelessWidget {
  final bool isLive;
  const _UserLocationMarker({required this.isLive});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: (isLive ? Colors.blue : AppColors.primary).withValues(alpha: 0.25),
          ),
        ),
        Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isLive ? Colors.blue.shade600 : AppColors.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Coffee Shop Marker Pin ───────────────────────────────────────────────────
class _CafeMarker extends StatelessWidget {
  final bool isSelected;
  final double? rating;

  const _CafeMarker({required this.isSelected, this.rating});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFE67E22) : AppColors.primary,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: isSelected ? 3 : 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.coffee,
          size: isSelected ? 24 : 18,
          color: Colors.white,
        ),
      ),
    );
  }
}

// ─── Map Action Floating Button ───────────────────────────────────────────────
class _MapActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;

  const _MapActionButton({
    required this.icon,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: iconColor ?? AppColors.textPrimary, size: 20),
        onPressed: onTap,
      ),
    );
  }
}

// ─── Place Preview Card (Bottom Floating) ─────────────────────────────────────
class _PlacePreviewCard extends StatelessWidget {
  final PlaceModel place;
  final VoidCallback onClose;
  final VoidCallback onDetail;
  final VoidCallback onNavigate;

  const _PlacePreviewCard({
    required this.place,
    required this.onClose,
    required this.onDetail,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row: Image + Details + Close
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cafe Photo
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 74,
                  height: 74,
                  child: place.imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: place.imageUrl!,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => Container(
                            color: AppColors.accent,
                            child: const Icon(Icons.coffee, color: AppColors.primary),
                          ),
                        )
                      : Container(
                          color: AppColors.accent,
                          child: const Icon(Icons.coffee, color: AppColors.primary),
                        ),
                ),
              ),
              const SizedBox(width: 12),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.name,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      place.address ?? 'Sidoarjo',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        // Rating
                        const Icon(Icons.star_rounded, size: 16, color: Color(0xFFF39C12)),
                        const SizedBox(width: 2),
                        Text(
                          place.rating?.toStringAsFixed(1) ?? '4.5',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),

                        // Distance tag
                        if (place.formattedDistance.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.directions_walk, size: 12, color: AppColors.primary),
                                const SizedBox(width: 2),
                                Text(
                                  place.formattedDistance,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],

                        // Price
                        Expanded(
                          child: Text(
                            place.priceRange,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
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

              // Close Button
              InkWell(
                onTap: onClose,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(Icons.close, size: 18, color: Colors.grey.shade400),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Action Buttons: "Petunjuk Arah" & "Lihat Detail"
          Row(
            children: [
              // Petunjuk Arah (Opens Google Maps)
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: OutlinedButton.icon(
                    onPressed: onNavigate,
                    icon: const Icon(Icons.directions, size: 18, color: AppColors.primary),
                    label: const Text(
                      'Petunjuk Arah',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary, width: 1.2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Lihat Detail
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: onDetail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text(
                      'Lihat Detail',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

