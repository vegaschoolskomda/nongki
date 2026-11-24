import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/place_model.dart';
import '../models/menu_item_model.dart';
import '../models/category_model.dart';
import '../models/activity_log_model.dart';
import '../models/order_model.dart';
import '../mock/mock_data.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._internal();
  AppDatabase._internal();

  static const String _keyUsers = 'nongki_users_v3';
  static const String _keyCurrentUser = 'nongki_current_user_v3';
  static const String _keyCustomPlaces = 'nongki_custom_places_v3';
  static const String _keyCustomMenus = 'nongki_custom_menus_v3';
  static const String _keyCategories = 'nongki_categories_v3';
  static const String _keyActivityLogs = 'nongki_activity_logs_v3';
  static const String _keyOrders = 'nongki_orders_v3';

  SharedPreferences? _prefs;
  bool _initialized = false;

  final List<UserModel> _users = [];
  final List<PlaceModel> _customPlaces = [];
  final List<MenuItemModel> _customMenus = [];
  final List<CategoryModel> _categories = [];
  final List<ActivityLogModel> _logs = [];
  final List<OrderModel> _orders = [];
  UserModel? _currentUser;

  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();

    _loadUsers();
    _loadCustomPlaces();
    _loadCustomMenus();
    _loadCategories();
    _loadLogs();
    _loadOrders();
    _loadCurrentUser();

    _initialized = true;
  }

  // ─── USERS ────────────────────────────────────────────────────────────────
  void _loadUsers() {
    final raw = _prefs?.getString(_keyUsers);
    if (raw != null && raw.isNotEmpty) {
      try {
        final list = jsonDecode(raw) as List;
        _users.clear();
        for (final item in list) {
          _users.add(UserModel.fromMap(item as Map<String, dynamic>));
        }
      } catch (_) {}
    }

    // Always ensure Bootstrap Admin & Seed Accounts exist
    _ensureSeedUsers();
  }

  void _ensureSeedUsers() {
    // 1. Admin Bootstrap Account — always force password & status
    final adminIdx = _users.indexWhere((u) => u.username == 'admin' || u.role == 'admin');
    if (adminIdx == -1) {
      _users.add(
        UserModel(
          id: 'usr_admin_001',
          name: 'Administrator NONGKI',
          username: 'admin',
          email: 'admin@nongki.dev',
          password: 'admin123',
          role: 'admin',
          status: 'active',
          createdAt: DateTime.now().subtract(const Duration(days: 90)),
        ),
      );
    } else {
      // Always enforce correct password & active status for admin seed
      _users[adminIdx] = _users[adminIdx].copyWith(
        password: 'admin123',
        status: 'active',
        role: 'admin',
      );
    }

    // 2. Seed Merchant Demo — Es Coklat Impian (verified, storeId plc_featured)
    if (!_users.any((u) => u.username == 'merchant_impian')) {
      _users.add(
        UserModel(
          id: 'usr_merchant_001',
          name: 'Bambang Sudarsono',
          username: 'merchant_impian',
          email: 'bambang@coklatimpian.id',
          password: 'merchant123',
          role: 'merchant',
          storeId: 'plc_featured',
          storeName: 'Es Coklat Impian',
          status: 'active',
          createdAt: DateTime.now().subtract(const Duration(days: 45)),
        ),
      );
    } else {
      // Ensure merchant demo password is always correct
      final mIdx = _users.indexWhere((u) => u.username == 'merchant_impian');
      if (mIdx != -1) {
        _users[mIdx] = _users[mIdx].copyWith(password: 'merchant123', status: 'active');
      }
    }

    // 2b. Seed Merchant Demo 2 — Kopi Nusantara (linked to CSV cafe)
    if (!_users.any((u) => u.username == 'merchant_kopi')) {
      _users.add(
        UserModel(
          id: 'usr_merchant_002',
          name: 'Sari Dewi',
          username: 'merchant_kopi',
          email: 'sari@kopinusantara.id',
          password: 'merchant123',
          role: 'merchant',
          storeId: 'plc_kopi_nusantara',
          storeName: 'Kopi Nusantara',
          status: 'active',
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
        ),
      );
    }

    // 3. Seed Cashier
    if (!_users.any((u) => u.username == 'kasir_impian')) {
      _users.add(
        UserModel(
          id: 'usr_cashier_001',
          name: 'Budi Santoso',
          username: 'kasir_impian',
          email: 'budi.kasir@coklatimpian.id',
          password: 'kasir123',
          role: 'cashier',
          storeId: 'plc_featured',
          storeName: 'Es Coklat Impian',
          status: 'active',
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
        ),
      );
    } else {
      final cIdx = _users.indexWhere((u) => u.username == 'kasir_impian');
      if (cIdx != -1) {
        _users[cIdx] = _users[cIdx].copyWith(password: 'kasir123', status: 'active');
      }
    }

    // 4. Seed Customer (Vega)
    if (!_users.any((u) => u.username == 'vega' || u.email == 'vega@nongki.id')) {
      _users.add(
        UserModel(
          id: 'usr_dev_001',
          name: 'Vega',
          username: 'vega',
          email: 'vega@nongki.id',
          password: 'user123',
          role: 'customer',
          status: 'active',
          createdAt: DateTime.now().subtract(const Duration(days: 60)),
        ),
      );
    } else {
      final vIdx = _users.indexWhere((u) => u.username == 'vega');
      if (vIdx != -1) {
        _users[vIdx] = _users[vIdx].copyWith(password: 'user123', status: 'active');
      }
    }

    _persistUsers();
  }

  Future<void> _persistUsers() async {
    final list = _users.map((u) => u.toMap()).toList();
    await _prefs?.setString(_keyUsers, jsonEncode(list));
  }

  List<UserModel> getUsers() => List.unmodifiable(_users);

  UserModel? getUserByUsernameOrEmail(String identifier) {
    final clean = identifier.trim().toLowerCase();
    try {
      return _users.firstWhere(
        (u) => u.username.toLowerCase() == clean || u.email.toLowerCase() == clean,
      );
    } catch (_) {
      return null;
    }
  }

  UserModel? getUserById(String id) {
    try {
      return _users.firstWhere((u) => u.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<UserModel> saveUser(UserModel user) async {
    final idx = _users.indexWhere((u) => u.id == user.id);
    if (idx != -1) {
      _users[idx] = user;
    } else {
      _users.add(user);
    }
    await _persistUsers();

    if (_currentUser?.id == user.id) {
      _currentUser = user;
      await _persistCurrentUser();
    }
    return user;
  }

  Future<void> updateUserStatus(String userId, String status) async {
    final idx = _users.indexWhere((u) => u.id == userId);
    if (idx != -1) {
      _users[idx] = _users[idx].copyWith(status: status);
      await _persistUsers();
      if (_currentUser?.id == userId) {
        _currentUser = _users[idx];
        await _persistCurrentUser();
      }
    }
  }

  // ─── CURRENT USER SESSION ────────────────────────────────────────────────
  void _loadCurrentUser() {
    final raw = _prefs?.getString(_keyCurrentUser);
    if (raw != null && raw.isNotEmpty) {
      try {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        final user = UserModel.fromMap(map);
        // Sync with freshest user record from _users
        final fresh = getUserById(user.id);
        _currentUser = fresh ?? user;
      } catch (_) {
        _currentUser = getUserByUsernameOrEmail('vega');
      }
    } else {
      // Default initial session for dev is Vega (customer)
      _currentUser = getUserByUsernameOrEmail('vega');
    }
  }

  Future<void> _persistCurrentUser() async {
    if (_currentUser != null) {
      await _prefs?.setString(_keyCurrentUser, jsonEncode(_currentUser!.toMap()));
    } else {
      await _prefs?.remove(_keyCurrentUser);
    }
  }

  UserModel? getCurrentUser() => _currentUser;

  Future<void> setCurrentUser(UserModel? user) async {
    _currentUser = user;
    await _persistCurrentUser();
  }

  // ─── CUSTOM PLACES / STORES ──────────────────────────────────────────────
  void _loadCustomPlaces() {
    final raw = _prefs?.getString(_keyCustomPlaces);
    if (raw != null && raw.isNotEmpty) {
      try {
        final list = jsonDecode(raw) as List;
        _customPlaces.clear();
        for (final item in list) {
          _customPlaces.add(PlaceModel.fromMap(item as Map<String, dynamic>));
        }
      } catch (_) {}
    }

    // Ensure Es Coklat Impian exists as a linked merchant store
    if (!_customPlaces.any((p) => p.id == 'plc_featured')) {
      _customPlaces.add(
        const PlaceModel(
          id: 'plc_featured',
          name: 'Es Coklat Impian',
          category: 'Kafe',
          description:
              'Tempat nongki viral bernuansa industrial kayu dengan menu es coklat legendaris dan roti celup empuk.',
          address: 'Kavling DPR, Sidoarjo',
          daerah: 'Sidoarjo',
          kecamatan: 'Sidoarjo Kota',
          imageUrl: 'https://images.unsplash.com/photo-1554118811-1e0d58224f24?auto=format&fit=crop&w=800&q=80',
          imageUrls: [
            'https://images.unsplash.com/photo-1554118811-1e0d58224f24?auto=format&fit=crop&w=800&q=80',
            'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?auto=format&fit=crop&w=800&q=80',
          ],
          rating: 4.8,
          reviewCount: 145,
          priceMin: 12000,
          priceMax: 30000,
          openingHours: '09:00 - 22:00 WIB',
          isOpen: true,
          facilities: ['Wi-Fi Cepat', 'Stopkontak', 'Area Ber-AC', 'Musholla', 'Parkir Luas'],
          latitude: -7.4478,
          longitude: 112.7183,
          acceptsOrder: true,
          ownerId: 'usr_merchant_001',
          verificationStatus: 'verified',
        ),
      );
      _persistCustomPlaces();
    }
  }

  Future<void> _persistCustomPlaces() async {
    final list = _customPlaces.map((p) => p.toMap()).toList();
    await _prefs?.setString(_keyCustomPlaces, jsonEncode(list));
  }

  List<PlaceModel> getCustomPlaces() => List.unmodifiable(_customPlaces);

  PlaceModel? getPlaceById(String placeId) {
    try {
      return _customPlaces.firstWhere((p) => p.id == placeId);
    } catch (_) {
      return null;
    }
  }

  PlaceModel? getStoreByOwnerId(String ownerId) {
    try {
      return _customPlaces.firstWhere((p) => p.ownerId == ownerId);
    } catch (_) {
      return null;
    }
  }

  Future<PlaceModel> savePlace(PlaceModel place) async {
    final idx = _customPlaces.indexWhere((p) => p.id == place.id);
    if (idx != -1) {
      _customPlaces[idx] = place;
    } else {
      _customPlaces.insert(0, place);
    }
    await _persistCustomPlaces();
    return place;
  }

  Future<void> updatePlaceVerification(String placeId, String status) async {
    final idx = _customPlaces.indexWhere((p) => p.id == placeId);
    if (idx != -1) {
      _customPlaces[idx] = _customPlaces[idx].copyWith(verificationStatus: status);
      await _persistCustomPlaces();
    }
  }

  // ─── CUSTOM MENUS ────────────────────────────────────────────────────────
  void _loadCustomMenus() {
    final raw = _prefs?.getString(_keyCustomMenus);
    if (raw != null && raw.isNotEmpty) {
      try {
        final list = jsonDecode(raw) as List;
        _customMenus.clear();
        for (final item in list) {
          _customMenus.add(MenuItemModel.fromMap(item as Map<String, dynamic>));
        }
      } catch (_) {}
    }

    // Seed default menus for Es Coklat Impian if empty
    if (!_customMenus.any((m) => m.placeId == 'plc_featured')) {
      _customMenus.addAll([
        const MenuItemModel(
          id: 'menu_impian_1',
          placeId: 'plc_featured',
          name: 'Es Coklat Impian Original',
          category: 'Non-Kopi',
          price: 15000,
          description: 'Coklat murni racikan khas dengan es batu segar dan manis yang pas.',
          imageUrl: 'https://images.unsplash.com/photo-1541658016709-82535e94bc69?auto=format&fit=crop&w=800&q=80',
          isAvailable: true,
          stok: 50,
          satuanStok: 'gelas',
        ),
        const MenuItemModel(
          id: 'menu_impian_2',
          placeId: 'plc_featured',
          name: 'Roti Panggang Celup',
          category: 'Camilan',
          price: 10000,
          description: 'Roti tebal empuk dipanggang gurih, cocok dicelup ke es coklat.',
          imageUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=800&q=80',
          isAvailable: true,
          stok: 40,
          satuanStok: 'porsi',
        ),
        const MenuItemModel(
          id: 'menu_impian_3',
          placeId: 'plc_featured',
          name: 'Kopi Susu Coklat',
          category: 'Kopi',
          price: 18000,
          description: 'Perpaduan espresso bold dengan coklat impian dan fresh milk.',
          imageUrl: 'https://images.unsplash.com/photo-1517256064527-09c73fc73e38?auto=format&fit=crop&w=800&q=80',
          isAvailable: true,
          stok: 35,
          satuanStok: 'gelas',
        ),
      ]);
      _persistCustomMenus();
    }
  }

  Future<void> _persistCustomMenus() async {
    final list = _customMenus.map((m) => m.toMap()).toList();
    await _prefs?.setString(_keyCustomMenus, jsonEncode(list));
  }

  List<MenuItemModel> getMenusByPlaceId(String placeId) {
    final clean = placeId.trim().replaceAll('/', '_');
    final raw = placeId.trim().replaceAll('_', '/');
    return _customMenus.where((m) {
      return m.placeId == placeId ||
          m.placeId == clean ||
          m.placeId == raw ||
          m.placeId.replaceAll('/', '_') == clean;
    }).toList();
  }

  Future<MenuItemModel> saveMenuItem(MenuItemModel item) async {
    final idx = _customMenus.indexWhere((m) => m.id == item.id);
    if (idx != -1) {
      _customMenus[idx] = item;
    } else {
      _customMenus.add(item);
    }
    await _persistCustomMenus();
    return item;
  }

  Future<void> deleteMenuItem(String itemId) async {
    _customMenus.removeWhere((m) => m.id == itemId);
    await _persistCustomMenus();
  }

  // ─── CATEGORIES ──────────────────────────────────────────────────────────
  void _loadCategories() {
    final raw = _prefs?.getString(_keyCategories);
    if (raw != null && raw.isNotEmpty) {
      try {
        final list = jsonDecode(raw) as List;
        _categories.clear();
        for (final item in list) {
          _categories.add(CategoryModel.fromMap(item as Map<String, dynamic>));
        }
      } catch (_) {}
    }

    if (_categories.isEmpty) {
      _categories.addAll([
        const CategoryModel(id: 'cat_all', name: 'Semua', order: 0),
        const CategoryModel(id: 'cat_cafe', name: 'Kafe', order: 1),
        const CategoryModel(id: 'cat_outdoor', name: 'Outdoor', order: 2),
        const CategoryModel(id: 'cat_work', name: 'Working Space', order: 3),
        const CategoryModel(id: 'cat_resto', name: 'Restoran', order: 4),
        const CategoryModel(id: 'cat_kedai', name: 'Kedai', order: 5),
        const CategoryModel(id: 'cat_dessert', name: 'Dessert & Bakery', order: 6),
      ]);
      _persistCategories();
    }
  }

  Future<void> _persistCategories() async {
    final list = _categories.map((c) => c.toMap()).toList();
    await _prefs?.setString(_keyCategories, jsonEncode(list));
  }

  List<CategoryModel> getCategories() => List.unmodifiable(_categories);

  Future<CategoryModel> addCategory(String name) async {
    final id = 'cat_${DateTime.now().millisecondsSinceEpoch}';
    final category = CategoryModel(id: id, name: name.trim(), order: _categories.length);
    _categories.add(category);
    await _persistCategories();
    return category;
  }

  Future<void> updateCategory(CategoryModel category) async {
    final idx = _categories.indexWhere((c) => c.id == category.id);
    if (idx != -1) {
      _categories[idx] = category;
      await _persistCategories();
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    _categories.removeWhere((c) => c.id == categoryId);
    await _persistCategories();
  }

  // ─── ACTIVITY LOGS ───────────────────────────────────────────────────────
  void _loadLogs() {
    final raw = _prefs?.getString(_keyActivityLogs);
    if (raw != null && raw.isNotEmpty) {
      try {
        final list = jsonDecode(raw) as List;
        _logs.clear();
        for (final item in list) {
          _logs.add(ActivityLogModel.fromMap(item as Map<String, dynamic>));
        }
      } catch (_) {}
    }

    if (_logs.isEmpty) {
      _logs.addAll([
        ActivityLogModel(
          id: 'log_seed_1',
          action: 'SYSTEM_BOOTSTRAP',
          actorName: 'System',
          actorRole: 'system',
          details: 'Platform NONGKI diinisialisasi dengan konfigurasi multi-role aman.',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
        ),
        ActivityLogModel(
          id: 'log_seed_2',
          action: 'STORE_VERIFIED',
          actorName: 'admin',
          actorRole: 'admin',
          details: 'Toko Es Coklat Impian diverifikasi oleh Administrator.',
          timestamp: DateTime.now().subtract(const Duration(hours: 12)),
        ),
      ]);
      _persistLogs();
    }
  }

  Future<void> _persistLogs() async {
    final list = _logs.take(200).map((l) => l.toMap()).toList();
    await _prefs?.setString(_keyActivityLogs, jsonEncode(list));
  }

  List<ActivityLogModel> getLogs() {
    final copy = List<ActivityLogModel>.from(_logs);
    copy.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return List.unmodifiable(copy);
  }

  Future<void> logActivity({
    required String action,
    required String actorName,
    required String actorRole,
    required String details,
  }) async {
    final log = ActivityLogModel(
      id: 'log_${DateTime.now().millisecondsSinceEpoch}',
      action: action,
      actorName: actorName,
      actorRole: actorRole,
      details: details,
      timestamp: DateTime.now(),
    );
    _logs.insert(0, log);
    await _persistLogs();
  }

  // ─── ORDERS ──────────────────────────────────────────────────────────────
  void _loadOrders() {
    final raw = _prefs?.getString(_keyOrders);
    if (raw != null && raw.isNotEmpty) {
      try {
        final list = jsonDecode(raw) as List;
        _orders.clear();
        for (final item in list) {
          _orders.add(OrderModel.fromMap(item as Map<String, dynamic>));
        }
      } catch (_) {}
    }

    if (_orders.isEmpty) {
      _orders.addAll(MockData.orders);
      _persistOrders();
    }
  }

  Future<void> _persistOrders() async {
    final list = _orders.map((o) => o.toMap()).toList();
    await _prefs?.setString(_keyOrders, jsonEncode(list));
  }

  List<OrderModel> getOrders() {
    final copy = List<OrderModel>.from(_orders);
    copy.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(copy);
  }

  Future<OrderModel> saveOrder(OrderModel order) async {
    final idx = _orders.indexWhere((o) => o.id == order.id);
    if (idx != -1) {
      _orders[idx] = order;
    } else {
      _orders.insert(0, order);
    }
    await _persistOrders();
    return order;
  }

  Future<OrderModel> updateOrderStatus(String orderId, String newStatus) async {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx == -1) {
      throw Exception('Pesanan tidak ditemukan');
    }
    final existing = _orders[idx];
    final updated = existing.copyWith(
      status: newStatus,
      paymentStatus: newStatus == 'completed' ? 'paid' : existing.paymentStatus,
    );
    _orders[idx] = updated;
    await _persistOrders();
    return updated;
  }
}
