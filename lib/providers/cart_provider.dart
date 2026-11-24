import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/cart_item_model.dart';
import '../data/models/menu_item_model.dart';
import '../data/models/place_model.dart';

class CartState {
  final String? placeId;
  final String? placeName;
  final String? placeAddress;
  final String? placeImageUrl;
  final List<CartItemModel> items;
  final int serviceFee;

  const CartState({
    this.placeId,
    this.placeName,
    this.placeAddress,
    this.placeImageUrl,
    this.items = const [],
    this.serviceFee = 2000,
  });

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;

  int get totalItemsCount => items.fold(0, (sum, i) => sum + i.quantity);

  int get subtotal => items.fold(0, (sum, i) => sum + i.subtotal);

  int get total => isEmpty ? 0 : subtotal + serviceFee;

  CartState copyWith({
    String? placeId,
    String? placeName,
    String? placeAddress,
    String? placeImageUrl,
    List<CartItemModel>? items,
    int? serviceFee,
    bool clearPlace = false,
  }) {
    return CartState(
      placeId: clearPlace ? null : (placeId ?? this.placeId),
      placeName: clearPlace ? null : (placeName ?? this.placeName),
      placeAddress: clearPlace ? null : (placeAddress ?? this.placeAddress),
      placeImageUrl: clearPlace ? null : (placeImageUrl ?? this.placeImageUrl),
      items: items ?? this.items,
      serviceFee: serviceFee ?? this.serviceFee,
    );
  }
}

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(const CartState());

  /// Cek apakah item dari tempat ini bisa dimasukkan tanpa bentrok
  bool isDifferentPlace(String targetPlaceId) {
    if (state.isEmpty || state.placeId == null) return false;
    return state.placeId != targetPlaceId;
  }

  /// Tambah item ke keranjang
  void addItem(MenuItemModel item, PlaceModel place, {bool forceReplace = false}) {
    // Jika dari tempat berbeda dan forceReplace aktif, reset keranjang
    if (state.placeId != null && state.placeId != place.id) {
      if (!forceReplace) return;
      state = CartState(
        placeId: place.id,
        placeName: place.name,
        placeAddress: place.address,
        placeImageUrl: place.imageUrl,
        items: [CartItemModel(item: item, quantity: 1)],
      );
      return;
    }

    final currentItems = List<CartItemModel>.from(state.items);
    final existingIndex = currentItems.indexWhere((ci) => ci.item.id == item.id);

    if (existingIndex >= 0) {
      final existing = currentItems[existingIndex];
      currentItems[existingIndex] = existing.copyWith(quantity: existing.quantity + 1);
    } else {
      currentItems.add(CartItemModel(item: item, quantity: 1));
    }

    state = state.copyWith(
      placeId: place.id,
      placeName: place.name,
      placeAddress: place.address,
      placeImageUrl: place.imageUrl,
      items: currentItems,
    );
  }

  /// Update kuantitas
  void updateQuantity(String menuItemId, int newQuantity) {
    if (newQuantity <= 0) {
      removeItem(menuItemId);
      return;
    }

    final currentItems = List<CartItemModel>.from(state.items);
    final index = currentItems.indexWhere((ci) => ci.item.id == menuItemId);
    if (index >= 0) {
      currentItems[index] = currentItems[index].copyWith(quantity: newQuantity);
      state = state.copyWith(items: currentItems);
    }
  }

  /// Hapus item
  void removeItem(String menuItemId) {
    final currentItems = state.items.where((ci) => ci.item.id != menuItemId).toList();
    if (currentItems.isEmpty) {
      state = const CartState();
    } else {
      state = state.copyWith(items: currentItems);
    }
  }

  /// Update catatan item
  void updateNote(String menuItemId, String note) {
    final currentItems = List<CartItemModel>.from(state.items);
    final index = currentItems.indexWhere((ci) => ci.item.id == menuItemId);
    if (index >= 0) {
      currentItems[index] = currentItems[index].copyWith(note: note);
      state = state.copyWith(items: currentItems);
    }
  }

  /// Kosongkan keranjang
  void clear() {
    state = const CartState();
  }

  int getQuantity(String menuItemId) {
    final found = state.items.where((ci) => ci.item.id == menuItemId);
    if (found.isEmpty) return 0;
    return found.first.quantity;
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});
