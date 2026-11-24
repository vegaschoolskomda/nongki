import 'package:equatable/equatable.dart';
import 'menu_item_model.dart';

class CartItemModel extends Equatable {
  final MenuItemModel item;
  final int quantity;
  final String? note;

  const CartItemModel({
    required this.item,
    this.quantity = 1,
    this.note,
  });

  int get subtotal => item.price * quantity;

  CartItemModel copyWith({
    MenuItemModel? item,
    int? quantity,
    String? note,
  }) {
    return CartItemModel(
      item: item ?? this.item,
      quantity: quantity ?? this.quantity,
      note: note ?? this.note,
    );
  }

  @override
  List<Object?> get props => [item, quantity, note];
}

