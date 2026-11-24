import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/order_model.dart';
import '../data/models/place_model.dart';
import '../data/services/app_database.dart';
import 'auth_provider.dart';
import 'order_provider.dart';

class CashierState {
  final PlaceModel? store;
  final List<OrderModel> orders;
  final bool isLoading;
  final String? error;

  const CashierState({
    this.store,
    this.orders = const [],
    this.isLoading = false,
    this.error,
  });

  List<OrderModel> get activeOrders => orders.where((o) => o.status != 'completed' && o.status != 'cancelled').toList();
  List<OrderModel> get completedOrders => orders.where((o) => o.status == 'completed').toList();

  CashierState copyWith({
    PlaceModel? store,
    List<OrderModel>? orders,
    bool? isLoading,
    String? error,
  }) {
    return CashierState(
      store: store ?? this.store,
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class CashierNotifier extends StateNotifier<CashierState> {
  final Ref _ref;
  final AppDatabase _db = AppDatabase.instance;

  CashierNotifier(this._ref) : super(const CashierState()) {
    refreshData();
  }

  Future<void> refreshData() async {
    state = state.copyWith(isLoading: true);
    try {
      await _db.init();
      final user = _ref.read(authProvider).user;
      final storeId = user?.storeId ?? 'plc_featured';
      final store = _db.getPlaceById(storeId);

      final storeOrders = _db.getOrders().where((o) => o.placeId == storeId).toList();

      state = state.copyWith(
        store: store,
        orders: storeOrders,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> advanceStatus(String orderId, String nextStatus) async {
    await _ref.read(orderProvider.notifier).updateOrderStatus(orderId, nextStatus);
    await refreshData();
  }
}

final cashierProvider = StateNotifierProvider<CashierNotifier, CashierState>((ref) {
  return CashierNotifier(ref);
});
