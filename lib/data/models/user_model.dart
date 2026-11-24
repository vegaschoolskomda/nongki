import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String name;
  final String username;
  final String email;
  final String? phone;
  final String? avatarUrl;
  final String role; // 'customer', 'merchant', 'cashier', 'admin'
  final String? storeId; // For merchant and cashier
  final String? storeName; // Quick reference
  final String status; // 'active', 'suspended', 'pending'
  final String? password; // Stored securely in local DB for mock auth
  final bool mustChangePassword;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    this.phone,
    this.avatarUrl,
    this.role = 'customer',
    this.storeId,
    this.storeName,
    this.status = 'active',
    this.password,
    this.mustChangePassword = false,
    required this.createdAt,
  });

  bool get isAdmin => role == 'admin';
  bool get isMerchant => role == 'merchant';
  bool get isCashier => role == 'cashier';
  bool get isCustomer => role == 'customer';
  bool get isActive => status == 'active';

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      username: map['username']?.toString() ?? (map['email']?.toString().split('@').first ?? ''),
      email: map['email']?.toString() ?? '',
      phone: map['phone']?.toString(),
      avatarUrl: map['avatar_url']?.toString(),
      role: map['role']?.toString() ?? 'customer',
      storeId: map['store_id']?.toString(),
      storeName: map['store_name']?.toString(),
      status: map['status']?.toString() ?? 'active',
      password: map['password']?.toString(),
      mustChangePassword: map['must_change_password'] as bool? ?? false,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'phone': phone,
      'avatar_url': avatarUrl,
      'role': role,
      'store_id': storeId,
      'store_name': storeName,
      'status': status,
      'password': password,
      'must_change_password': mustChangePassword,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Clean map matching Supabase PostgreSQL `public.profiles` schema
  Map<String, dynamic> toSupabaseMap({bool includePassword = false}) {
    final map = <String, dynamic>{
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'role': role,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
    if (phone != null) map['phone'] = phone;
    if (avatarUrl != null) map['avatar_url'] = avatarUrl;
    if (storeId != null) map['store_id'] = storeId;
    if (storeName != null) map['store_name'] = storeName;
    if (includePassword && password != null) map['password'] = password;
    return map;
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? username,
    String? email,
    String? phone,
    String? avatarUrl,
    String? role,
    String? storeId,
    String? storeName,
    String? status,
    String? password,
    bool? mustChangePassword,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      storeId: storeId ?? this.storeId,
      storeName: storeName ?? this.storeName,
      status: status ?? this.status,
      password: password ?? this.password,
      mustChangePassword: mustChangePassword ?? this.mustChangePassword,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        username,
        email,
        phone,
        avatarUrl,
        role,
        storeId,
        storeName,
        status,
        mustChangePassword,
        createdAt,
      ];
}
