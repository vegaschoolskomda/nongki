import 'package:equatable/equatable.dart';

class OrderItemModel extends Equatable {
  final String menuItemId;
  final String name;
  final int price;
  final int quantity;
  final int subtotal;
  final String? note;

  const OrderItemModel({
    required this.menuItemId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.subtotal,
    this.note,
  });

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      menuItemId: map['menu_item_id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      price: (map['price'] as num?)?.toInt() ?? 0,
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
      subtotal: (map['subtotal'] as num?)?.toInt() ?? 0,
      note: map['note'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'menu_item_id': menuItemId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'subtotal': subtotal,
      'note': note,
    };
  }

  @override
  List<Object?> get props => [menuItemId, name, price, quantity, subtotal, note];
}

class OrderModel extends Equatable {
  final String id;
  final String orderNumber;
  final String userId;
  final String placeId;
  final String placeName;
  final String? placeAddress;
  final String? placeImageUrl;
  final List<OrderItemModel> items;
  final int subtotal;
  final int serviceFee;
  final int total;
  final String paymentMethod; // 'cash'
  final String paymentStatus; // 'unpaid', 'paid', 'cancelled'
  final String status; // 'pending_payment', 'processing', 'ready', 'completed', 'cancelled'
  final String diningOption; // 'dine_in' or 'takeaway'
  final String? tableNumber;
  final String? notes;
  final bool hasReviewed;
  final DateTime createdAt;

  const OrderModel({
    required this.id,
    required this.orderNumber,
    required this.userId,
    required this.placeId,
    required this.placeName,
    this.placeAddress,
    this.placeImageUrl,
    required this.items,
    required this.subtotal,
    this.serviceFee = 2000,
    required this.total,
    this.paymentMethod = 'cash',
    this.paymentStatus = 'unpaid',
    this.status = 'processing',
    this.diningOption = 'dine_in',
    this.tableNumber,
    this.notes,
    this.hasReviewed = false,
    required this.createdAt,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'] as String,
      orderNumber: map['order_number'] as String,
      userId: map['user_id'] as String,
      placeId: map['place_id'] as String,
      placeName: map['place_name'] as String? ?? 'Tempat Nongki',
      placeAddress: map['place_address'] as String?,
      placeImageUrl: map['place_image_url'] as String?,
      items: (map['items'] as List<dynamic>?)
              ?.map((item) => OrderItemModel.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
      subtotal: (map['subtotal'] as num?)?.toInt() ?? 0,
      serviceFee: (map['service_fee'] as num?)?.toInt() ?? 2000,
      total: (map['total'] as num?)?.toInt() ?? 0,
      paymentMethod: map['payment_method'] as String? ?? 'cash',
      paymentStatus: map['payment_status'] as String? ?? 'unpaid',
      status: map['status'] as String? ?? 'processing',
      diningOption: map['dining_option'] as String? ?? 'dine_in',
      tableNumber: map['table_number'] as String?,
      notes: map['notes'] as String?,
      hasReviewed: map['has_reviewed'] as bool? ?? false,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_number': orderNumber,
      'user_id': userId,
      'place_id': placeId,
      'place_name': placeName,
      'place_address': placeAddress,
      'place_image_url': placeImageUrl,
      'items': items.map((e) => e.toMap()).toList(),
      'subtotal': subtotal,
      'service_fee': serviceFee,
      'total': total,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'status': status,
      'dining_option': diningOption,
      'table_number': tableNumber,
      'notes': notes,
      'has_reviewed': hasReviewed,
      'created_at': createdAt.toIso8601String(),
    };
  }

  OrderModel copyWith({
    String? id,
    String? orderNumber,
    String? userId,
    String? placeId,
    String? placeName,
    String? placeAddress,
    String? placeImageUrl,
    List<OrderItemModel>? items,
    int? subtotal,
    int? serviceFee,
    int? total,
    String? paymentMethod,
    String? paymentStatus,
    String? status,
    String? diningOption,
    String? tableNumber,
    String? notes,
    bool? hasReviewed,
    DateTime? createdAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      userId: userId ?? this.userId,
      placeId: placeId ?? this.placeId,
      placeName: placeName ?? this.placeName,
      placeAddress: placeAddress ?? this.placeAddress,
      placeImageUrl: placeImageUrl ?? this.placeImageUrl,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      serviceFee: serviceFee ?? this.serviceFee,
      total: total ?? this.total,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      status: status ?? this.status,
      diningOption: diningOption ?? this.diningOption,
      tableNumber: tableNumber ?? this.tableNumber,
      notes: notes ?? this.notes,
      hasReviewed: hasReviewed ?? this.hasReviewed,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, orderNumber, status, paymentStatus, total];
}

