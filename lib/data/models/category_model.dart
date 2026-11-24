import 'package:equatable/equatable.dart';

class CategoryModel extends Equatable {
  final String id;
  final String name;
  final String? iconName;
  final bool isActive;
  final int order;

  const CategoryModel({
    required this.id,
    required this.name,
    this.iconName,
    this.isActive = true,
    this.order = 0,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      iconName: map['icon_name']?.toString(),
      isActive: map['is_active'] as bool? ?? true,
      order: (map['order'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon_name': iconName,
      'is_active': isActive,
      'order': order,
    };
  }

  CategoryModel copyWith({
    String? id,
    String? name,
    String? iconName,
    bool? isActive,
    int? order,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      isActive: isActive ?? this.isActive,
      order: order ?? this.order,
    );
  }

  @override
  List<Object?> get props => [id, name, isActive, order];
}
