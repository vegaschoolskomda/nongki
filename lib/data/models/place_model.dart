import 'package:equatable/equatable.dart';

class PlaceModel extends Equatable {
  final String id;
  final String name;
  final String category;
  final String? description;
  final String? address;
  final String? daerah;
  final String? kecamatan;
  final String? imageUrl;
  final List<String> imageUrls;
  final double? rating;
  final int reviewCount;
  final int priceMin;
  final int priceMax;
  final String? openingHours;
  final bool isOpen;
  final List<String> facilities;
  final double? latitude;
  final double? longitude;
  final bool acceptsOrder;
  final double? distanceInKm;
  final String? ownerId;
  final String verificationStatus; // 'verified', 'pending', 'rejected', 'suspended'

  const PlaceModel({
    required this.id,
    required this.name,
    required this.category,
    this.description,
    this.address,
    this.daerah,
    this.kecamatan,
    this.imageUrl,
    this.imageUrls = const [],
    this.rating,
    this.reviewCount = 0,
    required this.priceMin,
    required this.priceMax,
    this.openingHours,
    this.isOpen = true,
    this.facilities = const [],
    this.latitude,
    this.longitude,
    this.acceptsOrder = true,
    this.distanceInKm,
    this.ownerId,
    this.verificationStatus = 'verified',
  });

  bool get isVerified => verificationStatus == 'verified';
  bool get isPendingVerification => verificationStatus == 'pending';

  String get priceRange {
    if (priceMin == priceMax) {
      return 'Rp${_formatK(priceMin)}';
    }
    return 'Rp${_formatK(priceMin)} - ${_formatK(priceMax)}';
  }

  String _formatK(int val) {
    if (val >= 1000) return '${(val / 1000).round()}rb';
    return val.toString();
  }

  String get formattedDistance {
    if (distanceInKm == null) return '';
    if (distanceInKm! < 1.0) {
      return '${(distanceInKm! * 1000).round()} m';
    }
    return '${distanceInKm!.toStringAsFixed(1)} km';
  }

  factory PlaceModel.fromMap(Map<String, dynamic> map) {
    final rawId = map['id']?.toString() ?? '';
    return PlaceModel(
      id: rawId.replaceAll('/', '_'),
      name: map['name']?.toString() ?? '',
      category: map['category']?.toString() ?? 'Kafe',
      description: map['description']?.toString(),
      address: map['address']?.toString(),
      daerah: map['daerah']?.toString(),
      kecamatan: map['kecamatan']?.toString(),
      imageUrl: map['image_url']?.toString(),
      imageUrls: (map['image_urls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      rating: (map['rating'] as num?)?.toDouble() ?? 4.5,
      reviewCount: (map['review_count'] as num?)?.toInt() ?? 50,
      priceMin: (map['price_min'] as num?)?.toInt() ?? 10000,
      priceMax: (map['price_max'] as num?)?.toInt() ?? 35000,
      openingHours: map['opening_hours']?.toString(),
      isOpen: map['is_open'] as bool? ?? true,
      facilities: (map['facilities'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const ['Wi-Fi', 'Stopkontak', 'Area AC', 'Outdoor'],
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      acceptsOrder: map['accepts_order'] as bool? ?? true,
      distanceInKm: (map['distance_in_km'] as num?)?.toDouble(),
      ownerId: map['owner_id']?.toString(),
      verificationStatus: map['verification_status']?.toString() ?? 'verified',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'description': description,
      'address': address,
      'daerah': daerah,
      'kecamatan': kecamatan,
      'image_url': imageUrl,
      'image_urls': imageUrls,
      'rating': rating,
      'review_count': reviewCount,
      'price_min': priceMin,
      'price_max': priceMax,
      'opening_hours': openingHours,
      'is_open': isOpen,
      'facilities': facilities,
      'latitude': latitude,
      'longitude': longitude,
      'accepts_order': acceptsOrder,
      'distance_in_km': distanceInKm,
      'owner_id': ownerId,
      'verification_status': verificationStatus,
    };
  }

  /// Clean map matching Supabase PostgreSQL `public.places` schema
  Map<String, dynamic> toSupabaseMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      if (description != null) 'description': description,
      if (address != null) 'address': address,
      if (imageUrl != null) 'image_url': imageUrl,
      'image_urls': imageUrls,
      'rating': rating,
      'review_count': reviewCount,
      'price_min': priceMin,
      'price_max': priceMax,
      if (openingHours != null) 'opening_hours': openingHours,
      'is_open': isOpen,
      'facilities': facilities,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      'accepts_order': acceptsOrder,
      'created_at': DateTime.now().toIso8601String(),
    };
  }

  PlaceModel copyWith({
    String? id,
    String? name,
    String? category,
    String? description,
    String? address,
    String? daerah,
    String? kecamatan,
    String? imageUrl,
    List<String>? imageUrls,
    double? rating,
    int? reviewCount,
    int? priceMin,
    int? priceMax,
    String? openingHours,
    bool? isOpen,
    List<String>? facilities,
    double? latitude,
    double? longitude,
    bool? acceptsOrder,
    double? distanceInKm,
    String? ownerId,
    String? verificationStatus,
  }) {
    return PlaceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      address: address ?? this.address,
      daerah: daerah ?? this.daerah,
      kecamatan: kecamatan ?? this.kecamatan,
      imageUrl: imageUrl ?? this.imageUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      priceMin: priceMin ?? this.priceMin,
      priceMax: priceMax ?? this.priceMax,
      openingHours: openingHours ?? this.openingHours,
      isOpen: isOpen ?? this.isOpen,
      facilities: facilities ?? this.facilities,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      acceptsOrder: acceptsOrder ?? this.acceptsOrder,
      distanceInKm: distanceInKm ?? this.distanceInKm,
      ownerId: ownerId ?? this.ownerId,
      verificationStatus: verificationStatus ?? this.verificationStatus,
    );
  }

  @override
  List<Object?> get props => [id, name, category, distanceInKm, verificationStatus];
}
