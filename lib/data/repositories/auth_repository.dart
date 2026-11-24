import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../models/place_model.dart';
import '../services/app_database.dart';

abstract class AuthRepository {
  Future<UserModel?> getCurrentUser();
  Future<UserModel> login({required String identifier, required String password});
  Future<UserModel> registerCustomer({
    required String name,
    required String username,
    required String email,
    required String password,
  });
  Future<UserModel> registerMerchant({
    required String ownerName,
    required String storeName,
    required String category,
    required String phone,
    required String email,
    required String username,
    required String address,
    required String description,
    required String password,
  });
  Future<UserModel> createCashier({
    required String name,
    required String username,
    required String password,
    required String storeId,
    required String storeName,
  });
  Future<void> logout();
  Future<UserModel> updateProfile({required String name, String? phone});
  Future<List<UserModel>> getAllUsers();
  Future<void> setUserStatus(String userId, String status);
}

class LocalAuthRepository implements AuthRepository {
  final AppDatabase _db = AppDatabase.instance;

  @override
  Future<UserModel?> getCurrentUser() async {
    await _db.init();
    return _db.getCurrentUser();
  }

  @override
  Future<UserModel> login({required String identifier, required String password}) async {
    await _db.init();
    final cleanId = identifier.trim();
    if (cleanId.isEmpty || password.isEmpty) {
      throw Exception('Username/Email dan kata sandi wajib diisi.');
    }

    final user = _db.getUserByUsernameOrEmail(cleanId);
    if (user == null) {
      throw Exception('Akun tidak ditemukan. Periksa kembali username atau email kamu.');
    }

    // Verify password
    if (user.password != null && user.password != password) {
      throw Exception('Kata sandi salah. Silakan coba lagi.');
    }

    // Check account status
    if (user.status == 'suspended') {
      throw Exception('Akun Anda dinonaktifkan oleh Administrator. Hubungi support.');
    }

    await _db.setCurrentUser(user);
    await _db.logActivity(
      action: 'LOGIN',
      actorName: user.name,
      actorRole: user.role,
      details: '${user.name} (${user.role}) berhasil masuk ke aplikasi.',
    );

    return user;
  }

  @override
  Future<UserModel> registerCustomer({
    required String name,
    required String username,
    required String email,
    required String password,
  }) async {
    await _db.init();
    final cleanName = name.trim();
    final cleanUsername = username.trim().toLowerCase();
    final cleanEmail = email.trim().toLowerCase();

    if (cleanName.isEmpty) throw Exception('Nama lengkap wajib diisi.');
    if (cleanUsername.isEmpty) throw Exception('Username wajib diisi.');
    if (cleanEmail.isEmpty || !cleanEmail.contains('@')) throw Exception('Email valid wajib diisi.');
    if (password.length < 6) throw Exception('Kata sandi minimal 6 karakter.');

    // Check duplicate username or email
    if (_db.getUserByUsernameOrEmail(cleanUsername) != null) {
      throw Exception('Username sudah digunakan oleh akun lain.');
    }
    if (_db.getUserByUsernameOrEmail(cleanEmail) != null) {
      throw Exception('Email sudah terdaftar. Silakan login.');
    }

    final newUser = UserModel(
      id: 'usr_cust_${DateTime.now().millisecondsSinceEpoch}',
      name: cleanName,
      username: cleanUsername,
      email: cleanEmail,
      password: password,
      role: 'customer', // Strictly customer role
      status: 'active',
      createdAt: DateTime.now(),
    );

    await _db.saveUser(newUser);
    await _db.setCurrentUser(newUser);

    await _db.logActivity(
      action: 'REGISTER_CUSTOMER',
      actorName: cleanName,
      actorRole: 'customer',
      details: 'Pengguna baru mendaftar: $cleanName (@$cleanUsername).',
    );

    return newUser;
  }

  @override
  Future<UserModel> registerMerchant({
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
    await _db.init();
    final cleanOwner = ownerName.trim();
    final cleanStore = storeName.trim();
    final cleanUsername = username.trim().toLowerCase();
    final cleanEmail = email.trim().toLowerCase();

    if (cleanOwner.isEmpty) throw Exception('Nama pemilik usaha wajib diisi.');
    if (cleanStore.isEmpty) throw Exception('Nama toko / kafe wajib diisi.');
    if (cleanUsername.isEmpty) throw Exception('Username wajib diisi.');
    if (cleanEmail.isEmpty || !cleanEmail.contains('@')) throw Exception('Email valid wajib diisi.');
    if (password.length < 6) throw Exception('Kata sandi minimal 6 karakter.');

    if (_db.getUserByUsernameOrEmail(cleanUsername) != null) {
      throw Exception('Username sudah digunakan.');
    }
    if (_db.getUserByUsernameOrEmail(cleanEmail) != null) {
      throw Exception('Email sudah terdaftar.');
    }

    final merchantId = 'usr_merch_${DateTime.now().millisecondsSinceEpoch}';
    final storeId = 'store_${DateTime.now().millisecondsSinceEpoch}';

    // 1. Create merchant user
    final merchantUser = UserModel(
      id: merchantId,
      name: cleanOwner,
      username: cleanUsername,
      email: cleanEmail,
      phone: phone.trim(),
      password: password,
      role: 'merchant',
      storeId: storeId,
      storeName: cleanStore,
      status: 'active',
      createdAt: DateTime.now(),
    );

    // 2. Create store record in database (status pending verification)
    final newStore = PlaceModel(
      id: storeId,
      name: cleanStore,
      category: category.isNotEmpty ? category : 'Kafe',
      description: description.trim().isNotEmpty
          ? description.trim()
          : 'Kafe kuliner mitra UMKM NONGKI.',
      address: address.trim().isNotEmpty ? address.trim() : 'Lokasi Mitra NONGKI',
      daerah: 'Jawa Timur',
      kecamatan: 'Kecamatan',
      imageUrl: 'https://images.unsplash.com/photo-1554118811-1e0d58224f24?auto=format&fit=crop&w=800&q=80',
      priceMin: 10000,
      priceMax: 35000,
      openingHours: '09:00 - 22:00 WIB',
      isOpen: true,
      facilities: const ['Wi-Fi', 'Stopkontak', 'Area AC', 'Parkir'],
      ownerId: merchantId,
      verificationStatus: 'pending', // Pending verification by admin
      acceptsOrder: true,
    );

    await _db.savePlace(newStore);
    await _db.saveUser(merchantUser);
    await _db.setCurrentUser(merchantUser);

    await _db.logActivity(
      action: 'REGISTER_MERCHANT',
      actorName: cleanOwner,
      actorRole: 'merchant',
      details: 'Pendaftaran mitra UMKM baru: $cleanStore oleh $cleanOwner (Menunggu Verifikasi).',
    );

    return merchantUser;
  }

  @override
  Future<UserModel> createCashier({
    required String name,
    required String username,
    required String password,
    required String storeId,
    required String storeName,
  }) async {
    await _db.init();
    final cleanName = name.trim();
    final cleanUsername = username.trim().toLowerCase();

    if (cleanName.isEmpty) throw Exception('Nama karyawan kasir wajib diisi.');
    if (cleanUsername.isEmpty) throw Exception('Username kasir wajib diisi.');
    if (password.length < 4) throw Exception('PIN/Kata sandi minimal 4 karakter.');

    if (_db.getUserByUsernameOrEmail(cleanUsername) != null) {
      throw Exception('Username sudah digunakan.');
    }

    final cashierUser = UserModel(
      id: 'usr_cashier_${DateTime.now().millisecondsSinceEpoch}',
      name: cleanName,
      username: cleanUsername,
      email: '$cleanUsername@pos.$storeId.nongki',
      password: password,
      role: 'cashier',
      storeId: storeId,
      storeName: storeName,
      status: 'active',
      createdAt: DateTime.now(),
    );

    await _db.saveUser(cashierUser);

    final current = _db.getCurrentUser();
    await _db.logActivity(
      action: 'CREATE_CASHIER',
      actorName: current?.name ?? 'Merchant',
      actorRole: current?.role ?? 'merchant',
      details: 'Akun kasir $cleanName (@$cleanUsername) dibuat untuk toko $storeName.',
    );

    return cashierUser;
  }

  @override
  Future<void> logout() async {
    await _db.init();
    final current = _db.getCurrentUser();
    if (current != null) {
      await _db.logActivity(
        action: 'LOGOUT',
        actorName: current.name,
        actorRole: current.role,
        details: '${current.name} keluar dari sesi aplikasi.',
      );
    }
    await _db.setCurrentUser(null);
  }

  @override
  Future<UserModel> updateProfile({required String name, String? phone}) async {
    await _db.init();
    final current = _db.getCurrentUser();
    if (current == null) throw Exception('Pengguna belum login.');

    final updated = current.copyWith(name: name.trim(), phone: phone?.trim());
    await _db.saveUser(updated);
    return updated;
  }

  @override
  Future<List<UserModel>> getAllUsers() async {
    await _db.init();
    return _db.getUsers();
  }

  @override
  Future<void> setUserStatus(String userId, String status) async {
    await _db.init();
    await _db.updateUserStatus(userId, status);
  }
}

/// Hybrid Auth Repository: synchronizes authentication and profile data with Supabase Cloud
class HybridAuthRepository implements AuthRepository {
  final LocalAuthRepository _local = LocalAuthRepository();
  final AppDatabase _db = AppDatabase.instance;

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
  Future<UserModel?> getCurrentUser() => _local.getCurrentUser();

  @override
  Future<UserModel> login({required String identifier, required String password}) async {
    // 1. Try local login first (fast & offline-first)
    try {
      return await _local.login(identifier: identifier, password: password);
    } catch (localError) {
      // If local user not found and Supabase is configured, check Supabase profiles
      if (_isSupabaseConfigured) {
        try {
          final cleanId = identifier.trim().toLowerCase();
          final client = Supabase.instance.client;
          final res = await client
              .from('profiles')
              .select()
              .or('username.eq.$cleanId,email.eq.$cleanId')
              .maybeSingle();

          if (res != null) {
            final user = UserModel.fromMap(res);
            if (user.password != null && user.password != password) {
              throw Exception('Kata sandi salah. Silakan coba lagi.');
            }
            if (user.status == 'suspended') {
              throw Exception('Akun Anda dinonaktifkan oleh Administrator. Hubungi support.');
            }
            await _db.init();
            await _db.saveUser(user);
            await _db.setCurrentUser(user);
            await _db.logActivity(
              action: 'LOGIN',
              actorName: user.name,
              actorRole: user.role,
              details: '${user.name} (${user.role}) berhasil masuk ke aplikasi via Cloud.',
            );
            return user;
          }
        } catch (cloudErr) {
          if (cloudErr.toString().contains('Kata sandi salah') || cloudErr.toString().contains('dinonaktifkan')) {
            rethrow;
          }
          debugPrint('[AuthRepository] Cloud login check error: $cloudErr');
        }
      }
      rethrow;
    }
  }

  @override
  Future<UserModel> registerCustomer({
    required String name,
    required String username,
    required String email,
    required String password,
  }) async {
    final newUser = await _local.registerCustomer(
      name: name,
      username: username,
      email: email,
      password: password,
    );

    if (_isSupabaseConfigured) {
      try {
        final client = Supabase.instance.client;
        try {
          await client.from('profiles').upsert(newUser.toSupabaseMap(includePassword: true));
        } catch (_) {
          await client.from('profiles').upsert(newUser.toSupabaseMap(includePassword: false));
        }
        debugPrint('[AuthRepository] Cloud sync registerCustomer success: @${newUser.username}');
      } catch (e) {
        debugPrint('[AuthRepository] Cloud sync registerCustomer error: $e');
      }
    }
    return newUser;
  }

  @override
  Future<UserModel> registerMerchant({
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
    final merchantUser = await _local.registerMerchant(
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

    if (_isSupabaseConfigured) {
      try {
        final client = Supabase.instance.client;
        try {
          await client.from('profiles').upsert(merchantUser.toSupabaseMap(includePassword: true));
        } catch (_) {
          await client.from('profiles').upsert(merchantUser.toSupabaseMap(includePassword: false));
        }
        if (merchantUser.storeId != null) {
          final store = _db.getPlaceById(merchantUser.storeId!);
          if (store != null) {
            await client.from('places').upsert(store.toSupabaseMap());
          }
        }
        debugPrint('[AuthRepository] Cloud sync registerMerchant success: @${merchantUser.username}');
      } catch (e) {
        debugPrint('[AuthRepository] Cloud sync registerMerchant error: $e');
      }
    }
    return merchantUser;
  }

  @override
  Future<UserModel> createCashier({
    required String name,
    required String username,
    required String password,
    required String storeId,
    required String storeName,
  }) async {
    final cashier = await _local.createCashier(
      name: name,
      username: username,
      password: password,
      storeId: storeId,
      storeName: storeName,
    );
    if (_isSupabaseConfigured) {
      try {
        final client = Supabase.instance.client;
        try {
          await client.from('profiles').upsert(cashier.toSupabaseMap(includePassword: true));
        } catch (_) {
          await client.from('profiles').upsert(cashier.toSupabaseMap(includePassword: false));
        }
        debugPrint('[AuthRepository] Cloud sync createCashier success: @${cashier.username}');
      } catch (e) {
        debugPrint('[AuthRepository] Cloud sync createCashier error: $e');
      }
    }
    return cashier;
  }

  @override
  Future<void> logout() => _local.logout();

  @override
  Future<UserModel> updateProfile({required String name, String? phone}) async {
    final updated = await _local.updateProfile(name: name, phone: phone);
    if (_isSupabaseConfigured) {
      try {
        final client = Supabase.instance.client;
        await client.from('profiles').update({
          'name': updated.name,
          'phone': updated.phone,
        }).eq('id', updated.id);
      } catch (e) {
        debugPrint('[AuthRepository] Cloud sync updateProfile error: $e');
      }
    }
    return updated;
  }

  @override
  Future<List<UserModel>> getAllUsers() async {
    final localUsers = await _local.getAllUsers();
    if (_isSupabaseConfigured) {
      try {
        final client = Supabase.instance.client;
        final res = await client.from('profiles').select().order('created_at', ascending: false);
        final remote = (res as List).map((m) => UserModel.fromMap(m)).toList();
        if (remote.isNotEmpty) {
          final merged = List<UserModel>.from(localUsers);
          for (final r in remote) {
            final idx = merged.indexWhere((l) => l.id == r.id || l.username == r.username);
            if (idx >= 0) {
              merged[idx] = r;
            } else {
              merged.add(r);
            }
          }
          return merged;
        }
      } catch (_) {}
    }
    return localUsers;
  }

  @override
  Future<void> setUserStatus(String userId, String status) async {
    await _local.setUserStatus(userId, status);
    if (_isSupabaseConfigured) {
      try {
        final client = Supabase.instance.client;
        await client.from('profiles').update({'status': status}).eq('id', userId);
      } catch (_) {}
    }
  }
}
