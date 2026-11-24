import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order_model.dart';
import '../services/app_database.dart';

abstract class OrderRepository {
  Future<List<OrderModel>> getOrders(String userId);
  Future<List<OrderModel>> getAllOrders();
  Future<OrderModel?> getOrderById(String orderId);
  Future<OrderModel> createOrder(OrderModel order);
  Future<OrderModel> updateOrderStatus(String orderId, String newStatus);
  Future<void> cancelOrder(String orderId);
}

class LocalOrderRepository implements OrderRepository {
  final AppDatabase _db = AppDatabase.instance;

  @override
  Future<List<OrderModel>> getOrders(String userId) async {
    await _db.init();
    final list = _db.getOrders().where((o) => o.userId == userId).toList();
    return list;
  }

  @override
  Future<List<OrderModel>> getAllOrders() async {
    await _db.init();
    return _db.getOrders();
  }

  @override
  Future<OrderModel?> getOrderById(String orderId) async {
    await _db.init();
    try {
      return _db.getOrders().firstWhere((o) => o.id == orderId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<OrderModel> createOrder(OrderModel order) async {
    await _db.init();
    final saved = await _db.saveOrder(order);
    await _db.logActivity(
      action: 'ORDER_CREATED',
      actorName: 'Pelanggan',
      actorRole: 'customer',
      details: 'Pesanan #${order.orderNumber} dibuat di ${order.placeName} (Rp ${order.total}).',
    );
    return saved;
  }

  @override
  Future<OrderModel> updateOrderStatus(String orderId, String newStatus) async {
    await _db.init();
    final updated = await _db.updateOrderStatus(orderId, newStatus);
    await _db.logActivity(
      action: 'ORDER_STATUS_UPDATED',
      actorName: 'Operasional',
      actorRole: 'system',
      details: 'Pesanan #${updated.orderNumber} status diubah ke: $newStatus.',
    );
    return updated;
  }

  @override
  Future<void> cancelOrder(String orderId) async {
    await _db.init();
    await updateOrderStatus(orderId, 'cancelled');
  }
}

/// Hybrid Order Repository: syncs with Supabase Cloud in real-time, fallbacks to local DB
class HybridOrderRepository implements OrderRepository {
  final LocalOrderRepository _local = LocalOrderRepository();

  bool get _isSupabaseConfigured {
    try {
      final client = Supabase.instance.client;
      final url = client.rest.url.toString();
      return url.isNotEmpty && !url.contains('YOUR_PROJECT');
    } catch (_) {
      return false;
    }
  }

  @override
  Future<List<OrderModel>> getOrders(String userId) async {
    final localOrders = await _local.getOrders(userId);
    if (_isSupabaseConfigured) {
      try {
        final client = Supabase.instance.client;
        final res = await client.from('orders').select().eq('user_id', userId).order('created_at', ascending: false);
        final remote = (res as List).map((row) => OrderModel.fromMap(row)).toList();
        if (remote.isNotEmpty) {
          final merged = List<OrderModel>.from(localOrders);
          for (final r in remote) {
            if (!merged.any((l) => l.id == r.id)) merged.add(r);
          }
          return merged;
        }
      } catch (e) {
        debugPrint('[OrderRepository] Supabase getOrders fallback to local: $e');
      }
    }
    return localOrders;
  }

  @override
  Future<List<OrderModel>> getAllOrders() async {
    final localOrders = await _local.getAllOrders();
    if (_isSupabaseConfigured) {
      try {
        final client = Supabase.instance.client;
        final res = await client.from('orders').select().order('created_at', ascending: false);
        final remote = (res as List).map((row) => OrderModel.fromMap(row)).toList();
        if (remote.isNotEmpty) {
          final merged = List<OrderModel>.from(localOrders);
          for (final r in remote) {
            if (!merged.any((l) => l.id == r.id)) merged.add(r);
          }
          return merged;
        }
      } catch (e) {
        debugPrint('[OrderRepository] Supabase getAllOrders fallback to local: $e');
      }
    }
    return localOrders;
  }

  @override
  Future<OrderModel?> getOrderById(String orderId) async {
    final local = await _local.getOrderById(orderId);
    if (local != null) return local;

    if (_isSupabaseConfigured) {
      try {
        final client = Supabase.instance.client;
        final res = await client.from('orders').select().eq('id', orderId).maybeSingle();
        if (res != null) return OrderModel.fromMap(res);
      } catch (_) {}
    }
    return null;
  }

  @override
  Future<OrderModel> createOrder(OrderModel order) async {
    // 1. Always save locally first so user never loses their order
    final saved = await _local.createOrder(order);

    // 2. Sync to Supabase Cloud
    if (_isSupabaseConfigured) {
      try {
        final client = Supabase.instance.client;
        await client.from('orders').insert(order.toMap());
        debugPrint('[OrderRepository] Order #${order.orderNumber} successfully pushed to Supabase Cloud');
      } catch (e) {
        debugPrint('[OrderRepository] Failed to push order to Supabase (saved locally): $e');
      }
    }
    return saved;
  }

  @override
  Future<OrderModel> updateOrderStatus(String orderId, String newStatus) async {
    final updated = await _local.updateOrderStatus(orderId, newStatus);
    if (_isSupabaseConfigured) {
      try {
        final client = Supabase.instance.client;
        await client.from('orders').update({'status': newStatus}).eq('id', orderId);
        debugPrint('[OrderRepository] Order status updated in Supabase Cloud');
      } catch (e) {
        debugPrint('[OrderRepository] Failed to update status in Supabase: $e');
      }
    }
    return updated;
  }

  @override
  Future<void> cancelOrder(String orderId) async {
    await updateOrderStatus(orderId, 'cancelled');
  }
}
