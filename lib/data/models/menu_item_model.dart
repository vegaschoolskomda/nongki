import 'package:equatable/equatable.dart';

class MenuItemModel extends Equatable {
  final String id;
  final String placeId;
  final String name;
  final String? description;
  final int price;
  final String? imageUrl;
  final String category; // 'Kopi', 'Non-Kopi', 'Makanan', 'Camilan'
  final bool isAvailable;
  final int? stok;
  final String? satuanStok;

  const MenuItemModel({
    required this.id,
    required this.placeId,
    required this.name,
    this.description,
    required this.price,
    this.imageUrl,
    this.category = 'Kopi',
    this.isAvailable = true,
    this.stok,
    this.satuanStok,
  });

  factory MenuItemModel.fromMap(Map<String, dynamic> map) {
    final rawPlaceId = map['place_id']?.toString() ?? '';
    return MenuItemModel(
      id: map['id']?.toString() ?? '',
      placeId: rawPlaceId.replaceAll('/', '_'),
      name: map['name']?.toString() ?? '',
      description: map['description']?.toString(),
      price: (map['price'] as num?)?.toInt() ?? 0,
      imageUrl: map['image_url']?.toString(),
      category: map['category']?.toString() ?? 'Kopi',
      isAvailable: map['is_available'] as bool? ?? true,
      stok: (map['stok'] as num?)?.toInt(),
      satuanStok: map['satuan_stok']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'place_id': placeId,
      'name': name,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'category': category,
      'is_available': isAvailable,
      'stok': stok,
      'satuan_stok': satuanStok,
    };
  }

  MenuItemModel copyWith({
    String? id,
    String? placeId,
    String? name,
    String? description,
    int? price,
    String? imageUrl,
    String? category,
    bool? isAvailable,
    int? stok,
    String? satuanStok,
  }) {
    return MenuItemModel(
      id: id ?? this.id,
      placeId: placeId ?? this.placeId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      isAvailable: isAvailable ?? this.isAvailable,
      stok: stok ?? this.stok,
      satuanStok: satuanStok ?? this.satuanStok,
    );
  }

  @override
  List<Object?> get props => [id, placeId, name, price, isAvailable, stok];
}
