import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/user_model.dart';
import 'app_providers.dart';

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;
  final String? previewRole; // For Developer "View As" preview mode
  final bool isGuest; // Guest login mode (restricted, can explore & search but no online ordering)

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.previewRole,
    this.isGuest = false,
  });

  bool get isAuthenticated => user != null;
  bool get isGuestUser => isGuest || (user == null && previewRole == null);
  bool get canOrderOnline => true; // Always allow ordering for demo & guest browsing

  /// Effective role for UI view: respects previewRole if in preview mode
  String get effectiveRole {
    if (previewRole != null) return previewRole!;
    if (isGuest) return 'customer';
    return user?.role ?? 'customer';
  }

  bool get isCustomer => effectiveRole == 'customer';
  bool get isMerchant => effectiveRole == 'merchant';
  bool get isCashier => effectiveRole == 'cashier';
  bool get isAdmin => effectiveRole == 'admin';

  bool get isInPreviewMode => previewRole != null;

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? error,
    String? previewRole,
    bool? isGuest,
    bool clearUser = false,
    bool clearError = false,
    bool clearPreview = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      previewRole: clearPreview ? null : (previewRole ?? this.previewRole),
      isGuest: isGuest ?? this.isGuest,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref _ref;

  AuthNotifier(this._ref) : super(const AuthState()) {
    _init();
  }

  Future<void> _init() async {
    state = state.copyWith(isLoading: true);
    try {
      final user = await _ref.read(authRepositoryProvider).getCurrentUser();
      state = state.copyWith(user: user, isLoading: false, clearError: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> login(String identifier, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _ref.read(authRepositoryProvider).login(
            identifier: identifier,
            password: password,
          );
      state = state.copyWith(user: user, isLoading: false, clearPreview: true);
      _ref.invalidate(allUsersProvider);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> registerCustomer({
    required String name,
    required String username,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _ref.read(authRepositoryProvider).registerCustomer(
            name: name,
            username: username,
            email: email,
            password: password,
          );
      state = state.copyWith(user: user, isLoading: false, clearPreview: true);
      _ref.invalidate(allUsersProvider);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> registerMerchant({
    required String ownerName,
    required String storeName,
    required String category,
    required String phone,
    required String email,
    required String username,
    required String address,
    required String description,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _ref.read(authRepositoryProvider).registerMerchant(
            ownerName: ownerName,
            storeName: storeName,
            category: category,
            phone: phone,
            email: email,
            username: username,
            address: address,
            description: description,
            password: password,
          );
      state = state.copyWith(user: user, isLoading: false, clearPreview: true);
      _ref.invalidate(allUsersProvider);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> createCashier({
    required String name,
    required String username,
    required String password,
    required String storeId,
    required String storeName,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _ref.read(authRepositoryProvider).createCashier(
            name: name,
            username: username,
            password: password,
            storeId: storeId,
            storeName: storeName,
          );
      state = state.copyWith(isLoading: false);
      _ref.invalidate(allUsersProvider);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    try {
      await _ref.read(authRepositoryProvider).logout();
      state = const AuthState();
      _ref.invalidate(allUsersProvider);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void loginAsGuest() {
    state = const AuthState(isGuest: true);
  }

  Future<bool> updateProfile(String name, String? phone) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _ref.read(authRepositoryProvider).updateProfile(name: name, phone: phone);
      state = state.copyWith(user: user, isLoading: false);
      _ref.invalidate(allUsersProvider);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  Future<void> setUserStatus(String userId, String status) async {
    await _ref.read(authRepositoryProvider).setUserStatus(userId, status);
    _ref.invalidate(allUsersProvider);
    // If updating current user
    if (state.user?.id == userId) {
      final fresh = await _ref.read(authRepositoryProvider).getCurrentUser();
      state = state.copyWith(user: fresh);
    }
  }

  void setPreviewRole(String role) {
    state = state.copyWith(previewRole: role);
  }

  void clearPreviewRole() {
    state = state.copyWith(clearPreview: true);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});

final allUsersProvider = FutureProvider<List<UserModel>>((ref) async {
  return ref.watch(authRepositoryProvider).getAllUsers();
});
