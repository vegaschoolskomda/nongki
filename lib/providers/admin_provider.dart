import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/place_model.dart';
import '../data/models/category_model.dart';
import '../data/models/activity_log_model.dart';
import '../data/models/order_model.dart';
import '../data/services/app_database.dart';
import 'auth_provider.dart';

class AdminStats {
  final int totalUsers;
  final int totalCustomers;
  final int totalMerchants;
  final int totalCashiers;
  final int totalStores;
  final int activeStores;
  final int pendingStores;
  final int totalOrders;
  final int totalRevenue;

  const AdminStats({
    required this.totalUsers,
    required this.totalCustomers,
    required this.totalMerchants,
    required this.totalCashiers,
    required this.totalStores,
    required this.activeStores,
    required this.pendingStores,
    required this.totalOrders,
    required this.totalRevenue,
  });
}

class AdminState {
  final AdminStats stats;
  final List<PlaceModel> stores;
  final List<CategoryModel> categories;
  final List<ActivityLogModel> logs;
  final List<OrderModel> orders;
  final bool isLoading;
  final String? error;

  const AdminState({
    required this.stats,
    this.stores = const [],
    this.categories = const [],
    this.logs = const [],
    this.orders = const [],
    this.isLoading = false,
    this.error,
  });

  AdminState copyWith({
    AdminStats? stats,
    List<PlaceModel>? stores,
    List<CategoryModel>? categories,
    List<ActivityLogModel>? logs,
    List<OrderModel>? orders,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return AdminState(
      stats: stats ?? this.stats,
      stores: stores ?? this.stores,
      categories: categories ?? this.categories,
      logs: logs ?? this.logs,
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class AdminNotifier extends StateNotifier<AdminState> {
  final Ref _ref;
  final AppDatabase _db = AppDatabase.instance;

  AdminNotifier(this._ref)
      : super(
          const AdminState(
            stats: AdminStats(
              totalUsers: 0,
              totalCustomers: 0,
              totalMerchants: 0,
              totalCashiers: 0,
              totalStores: 0,
              activeStores: 0,
              pendingStores: 0,
              totalOrders: 0,
              totalRevenue: 0,
            ),
          ),
        ) {
    refreshData();
  }

  Future<void> refreshData() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _db.init();
      final users = _db.getUsers();
      final stores = _db.getCustomPlaces();
      final categories = _db.getCategories();
      final logs = _db.getLogs();
      final orders = _db.getOrders();

      int customers = 0;
      int merchants = 0;
      int cashiers = 0;
      for (final u in users) {
        if (u.isCustomer) customers++;
        if (u.isMerchant) merchants++;
        if (u.isCashier) cashiers++;
      }

      int activeStores = 0;
      int pendingStores = 0;
      for (final s in stores) {
        if (s.verificationStatus == 'pending') {
          pendingStores++;
        } else if (s.verificationStatus == 'verified' && s.isOpen) {
          activeStores++;
        }
      }

      int revenue = 0;
      for (final o in orders) {
        if (o.status == 'completed' || o.paymentStatus == 'paid') {
          revenue += o.total;
        }
      }

      final stats = AdminStats(
        totalUsers: users.length,
        totalCustomers: customers,
        totalMerchants: merchants,
        totalCashiers: cashiers,
        totalStores: stores.length,
        activeStores: activeStores,
        pendingStores: pendingStores,
        totalOrders: orders.length,
        totalRevenue: revenue,
      );

      state = state.copyWith(
        stats: stats,
        stores: stores,
        categories: categories,
        logs: logs,
        orders: orders,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> verifyStore(String storeId, bool approve) async {
    final status = approve ? 'verified' : 'rejected';
    await _db.updatePlaceVerification(storeId, status);
    final store = _db.getPlaceById(storeId);
    final adminUser = _ref.read(authProvider).user;

    await _db.logActivity(
      action: approve ? 'STORE_APPROVED' : 'STORE_REJECTED',
      actorName: adminUser?.name ?? 'Admin',
      actorRole: 'admin',
      details: 'Pengajuan toko "${store?.name ?? storeId}" ${approve ? "disetujui" : "ditolak"} oleh Admin.',
    );

    await refreshData();
  }

  Future<void> setStoreVerification(String storeId, String status) async {
    await _db.updatePlaceVerification(storeId, status);
    final store = _db.getPlaceById(storeId);
    final adminUser = _ref.read(authProvider).user;

    await _db.logActivity(
      action: 'STORE_STATUS_CHANGED',
      actorName: adminUser?.name ?? 'Admin',
      actorRole: 'admin',
      details: 'Status verifikasi toko "${store?.name ?? storeId}" diubah menjadi: $status.',
    );

    await refreshData();
  }

  Future<void> addCategory(String name) async {
    if (name.trim().isEmpty) return;
    await _db.addCategory(name.trim());
    final adminUser = _ref.read(authProvider).user;

    await _db.logActivity(
      action: 'CATEGORY_CREATED',
      actorName: adminUser?.name ?? 'Admin',
      actorRole: 'admin',
      details: 'Kategori baru "$name" ditambahkan ke platform.',
    );

    await refreshData();
  }

  Future<void> updateCategory(CategoryModel category) async {
    await _db.updateCategory(category);
    await refreshData();
  }

  Future<void> deleteCategory(String categoryId) async {
    await _db.deleteCategory(categoryId);
    final adminUser = _ref.read(authProvider).user;

    await _db.logActivity(
      action: 'CATEGORY_DELETED',
      actorName: adminUser?.name ?? 'Admin',
      actorRole: 'admin',
      details: 'Kategori $categoryId dihapus dari sistem.',
    );

    await refreshData();
  }

  Future<void> toggleUserStatus(String userId, String currentStatus) async {
    final newStatus = currentStatus == 'active' ? 'suspended' : 'active';
    await _db.updateUserStatus(userId, newStatus);
    final targetUser = _db.getUserById(userId);
    final adminUser = _ref.read(authProvider).user;

    await _db.logActivity(
      action: newStatus == 'suspended' ? 'USER_SUSPENDED' : 'USER_ACTIVATED',
      actorName: adminUser?.name ?? 'Admin',
      actorRole: 'admin',
      details: 'Akun "${targetUser?.name ?? userId}" di-${newStatus == "suspended" ? "nonaktifkan" : "aktifkan kembali"}.',
    );

    _ref.invalidate(allUsersProvider);
    await refreshData();
  }
}

final adminProvider = StateNotifierProvider<AdminNotifier, AdminState>((ref) {
  return AdminNotifier(ref);
});
