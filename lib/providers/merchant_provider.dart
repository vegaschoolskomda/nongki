import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/place_model.dart';
import '../data/models/menu_item_model.dart';
import '../data/models/user_model.dart';
import '../data/models/order_model.dart';
import '../data/services/app_database.dart';
import '../data/services/csv_data_service.dart';
import 'auth_provider.dart';
import 'order_provider.dart';

class MerchantState {
  final PlaceModel? store;
  final List<MenuItemModel> menus;
  final List<UserModel> cashiers;
  final List<OrderModel> orders;
  final bool isLoading;
  final String? error;

  const MerchantState({
    this.store,
    this.menus = const [],
    this.cashiers = const [],
    this.orders = const [],
    this.isLoading = false,
    this.error,
  });

  MerchantState copyWith({
    PlaceModel? store,
    List<MenuItemModel>? menus,
    List<UserModel>? cashiers,
    List<OrderModel>? orders,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return MerchantState(
      store: store ?? this.store,
      menus: menus ?? this.menus,
      cashiers: cashiers ?? this.cashiers,
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class MerchantNotifier extends StateNotifier<MerchantState> {
  final Ref _ref;
  final AppDatabase _db = AppDatabase.instance;

  MerchantNotifier(this._ref) : super(const MerchantState()) {
    refreshData();
  }

  Future<void> refreshData() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _db.init();
      final currentUser = _ref.read(authProvider).user;
      if (currentUser == null) {
        state = const MerchantState();
        return;
      }

      // Find store by storeId or ownerId
      PlaceModel? store;
      if (currentUser.storeId != null && currentUser.storeId!.isNotEmpty) {
        store = _db.getPlaceById(currentUser.storeId!);
      }
      store ??= _db.getStoreByOwnerId(currentUser.id);

      // Default fallback for demo if merchant is attached to plc_featured
      if (store == null && (currentUser.isMerchant || currentUser.isAdmin)) {
        store = _db.getPlaceById('plc_featured');
      }

      final storeId = store?.id ?? currentUser.storeId ?? 'plc_featured';

      // Load menus
      final menus = _db.getMenusByPlaceId(storeId);

      // Load cashiers for this store
      final cashiers = _db.getUsers().where((u) => u.isCashier && u.storeId == storeId).toList();

      // Load incoming orders for this store
      final orders = _db.getOrders().where((o) => o.placeId == storeId).toList();

      state = state.copyWith(
        store: store,
        menus: menus,
        cashiers: cashiers,
        orders: orders,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateStoreInfo({
    String? name,
    String? category,
    String? address,
    String? openingHours,
    String? description,
    bool? isOpen,
  }) async {
    if (state.store == null) return;
    final updated = state.store!.copyWith(
      name: name ?? state.store!.name,
      category: category ?? state.store!.category,
      address: address ?? state.store!.address,
      openingHours: openingHours ?? state.store!.openingHours,
      description: description ?? state.store!.description,
      isOpen: isOpen ?? state.store!.isOpen,
    );

    await _db.savePlace(updated);
    final user = _ref.read(authProvider).user;
    await _db.logActivity(
      action: 'UPDATE_STORE_INFO',
      actorName: user?.name ?? 'Merchant',
      actorRole: 'merchant',
      details: 'Pengaturan toko "${updated.name}" diperbarui (Buka: ${updated.isOpen ? "Ya" : "Tutup"}).',
    );

    await refreshData();
  }

  Future<void> addMenuItem({
    required String name,
    required String category,
    required int price,
    String? description,
    int? stok,
    String? satuanStok,
    String? imageUrl,
  }) async {
    final storeId = state.store?.id ?? 'plc_featured';
    final resolvedPhoto = (imageUrl != null && imageUrl.trim().isNotEmpty)
        ? imageUrl.trim()
        : CsvDataService.resolveMenuPhoto(name);

    final newItem = MenuItemModel(
      id: 'menu_${DateTime.now().millisecondsSinceEpoch}',
      placeId: storeId,
      name: name.trim(),
      category: category,
      price: price,
      description: description?.trim(),
      stok: stok ?? 50,
      satuanStok: satuanStok ?? 'porsi',
      isAvailable: true,
      imageUrl: resolvedPhoto,
    );

    await _db.saveMenuItem(newItem);
    final user = _ref.read(authProvider).user;
    await _db.logActivity(
      action: 'ADD_MENU_ITEM',
      actorName: user?.name ?? 'Merchant',
      actorRole: 'merchant',
      details: 'Menu baru "$name" (Rp $price) ditambahkan ke toko ${state.store?.name}.',
    );

    await refreshData();
  }

  Future<void> updateMenuItem(MenuItemModel item) async {
    await _db.saveMenuItem(item);
    final user = _ref.read(authProvider).user;
    await _db.logActivity(
      action: 'UPDATE_MENU_ITEM',
      actorName: user?.name ?? 'Merchant',
      actorRole: 'merchant',
      details: 'Perubahan harga/stok menu "${item.name}" disimpan ke database (Rp ${item.price}, Stok: ${item.stok}).',
    );

    await refreshData();
  }

  Future<void> deleteMenuItem(String itemId) async {
    await _db.deleteMenuItem(itemId);
    final user = _ref.read(authProvider).user;
    await _db.logActivity(
      action: 'DELETE_MENU_ITEM',
      actorName: user?.name ?? 'Merchant',
      actorRole: 'merchant',
      details: 'Menu $itemId dihapus dari toko ${state.store?.name}.',
    );

    await refreshData();
  }

  Future<bool> createCashier({
    required String name,
    required String username,
    required String password,
  }) async {
    final store = state.store;
    final storeId = store?.id ?? 'plc_featured';
    final storeName = store?.name ?? 'Toko Mitra';

    final success = await _ref.read(authProvider.notifier).createCashier(
          name: name,
          username: username,
          password: password,
          storeId: storeId,
          storeName: storeName,
        );

    if (success) {
      await refreshData();
    }
    return success;
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    await _ref.read(orderProvider.notifier).updateOrderStatus(orderId, newStatus);
    await refreshData();
  }
}

final merchantProvider = StateNotifierProvider<MerchantNotifier, MerchantState>((ref) {
  return MerchantNotifier(ref);
});
