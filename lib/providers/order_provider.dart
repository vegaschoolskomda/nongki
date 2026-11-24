import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/order_model.dart';
import '../data/models/user_model.dart';
import 'app_providers.dart';
import 'auth_provider.dart';
import 'cart_provider.dart';
import 'points_provider.dart';

class OrderState {
  final List<OrderModel> orders;
  final bool isLoading;
  final String? error;

  const OrderState({
    this.orders = const [],
    this.isLoading = false,
    this.error,
  });

  OrderState copyWith({
    List<OrderModel>? orders,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return OrderState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class OrderNotifier extends StateNotifier<OrderState> {
  final Ref _ref;

  OrderNotifier(this._ref) : super(const OrderState()) {
    loadOrders();
  }

  Future<void> loadOrders() async {
    final user = _ref.read(authProvider).user;
    if (user == null) {
      state = state.copyWith(orders: []);
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final orders = await _ref.read(orderRepositoryProvider).getOrders(user.id);
      state = state.copyWith(orders: orders, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Buat pesanan baru
  Future<OrderModel> createOrder({
    required String diningOption,
    String? tableNumber,
    String? notes,
    String paymentMethod = 'cash',
    String paymentStatus = 'unpaid',
  }) async {
    final user = _ref.read(authProvider).user ??
        UserModel(
          id: 'usr_guest_${DateTime.now().millisecondsSinceEpoch}',
          name: 'Pelanggan Nongki (Tamu)',
          username: 'tamu_${DateTime.now().millisecondsSinceEpoch % 1000}',
          email: 'tamu@nongki.app',
          role: 'customer',
          status: 'active',
          createdAt: DateTime.now(),
        );

    final cart = _ref.read(cartProvider);
    if (cart.isEmpty || cart.placeId == null) {
      throw Exception('Keranjang belanja masih kosong');
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final orderNumber = 'NGK-${DateTime.now().year}${DateTime.now().month.toString().padLeft(2, '0')}${DateTime.now().day.toString().padLeft(2, '0')}-${DateTime.now().millisecond.toString().padLeft(3, '0')}';

      final newOrder = OrderModel(
        id: 'ord_${DateTime.now().millisecondsSinceEpoch}',
        orderNumber: orderNumber,
        userId: user.id,
        placeId: cart.placeId!,
        placeName: cart.placeName ?? 'Tempat Nongki',
        placeAddress: cart.placeAddress,
        placeImageUrl: cart.placeImageUrl,
        items: cart.items.map((ci) {
          return OrderItemModel(
            menuItemId: ci.item.id,
            name: ci.item.name,
            price: ci.item.price,
            quantity: ci.quantity,
            subtotal: ci.subtotal,
            note: ci.note,
          );
        }).toList(),
        subtotal: cart.subtotal,
        serviceFee: cart.serviceFee,
        total: cart.total,
        paymentMethod: paymentMethod,
        paymentStatus: paymentStatus,
        status: 'pending_confirmation', // Menunggu konfirmasi kasir
        diningOption: diningOption,
        tableNumber: tableNumber,
        notes: notes,
        createdAt: DateTime.now(),
      );

      final created = await _ref.read(orderRepositoryProvider).createOrder(newOrder);

      // Bersihkan keranjang
      _ref.read(cartProvider.notifier).clear();

      // Update state order
      state = state.copyWith(
        orders: [created, ...state.orders],
        isLoading: false,
      );

      return created;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  /// Update status pesanan (digunakan oleh Merchant / Kasir & Live Tracking)
  Future<OrderModel> updateOrderStatus(String orderId, String newStatus) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final updatedOrder = await _ref.read(orderRepositoryProvider).updateOrderStatus(orderId, newStatus);

      final updatedList = state.orders.map((o) {
        if (o.id == orderId) {
          return updatedOrder;
        }
        return o;
      }).toList();

      state = state.copyWith(orders: updatedList, isLoading: false);

      // Jika pesanan selesai, berikan poin loyalitas ke pelanggan
      if (newStatus == 'completed') {
        await _ref.read(pointsProvider.notifier).awardPointsForOrder(updatedOrder);
      }

      return updatedOrder;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> cancelOrder(String orderId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _ref.read(orderRepositoryProvider).cancelOrder(orderId);
      final updated = state.orders.map((o) {
        if (o.id == orderId) {
          return o.copyWith(status: 'cancelled', paymentStatus: 'cancelled');
        }
        return o;
      }).toList();
      state = state.copyWith(orders: updated, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  void markOrderAsReviewed(String orderId) {
    final updated = state.orders.map((o) {
      if (o.id == orderId) {
        return o.copyWith(hasReviewed: true);
      }
      return o;
    }).toList();
    state = state.copyWith(orders: updated);
  }
}

final orderProvider = StateNotifierProvider<OrderNotifier, OrderState>((ref) {
  return OrderNotifier(ref);
});

final orderDetailProvider = FutureProvider.family<OrderModel?, String>((ref, orderId) async {
  // Watch orderProvider so changes (such as status updates) trigger automatic re-evaluation
  final orderState = ref.watch(orderProvider);
  final foundInState = orderState.orders.where((o) => o.id == orderId);
  if (foundInState.isNotEmpty) {
    return foundInState.first;
  }
  final repo = ref.watch(orderRepositoryProvider);
  return repo.getOrderById(orderId);
});

final allOrdersProvider = FutureProvider<List<OrderModel>>((ref) async {
  ref.watch(orderProvider); // Trigger reload on updates
  final repo = ref.watch(orderRepositoryProvider);
  return repo.getAllOrders();
});
