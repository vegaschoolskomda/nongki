import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/order_model.dart';

class PointsReward {
  final String id;
  final String title;
  final int pointsRequired;
  final String discountFormatted;
  final String description;
  final String category;

  const PointsReward({
    required this.id,
    required this.title,
    required this.pointsRequired,
    required this.discountFormatted,
    required this.description,
    required this.category,
  });
}

class PointsHistory {
  final String id;
  final String? orderId;
  final String title;
  final int points;
  final String type; // 'earn' or 'redeem'
  final DateTime date;

  const PointsHistory({
    required this.id,
    this.orderId,
    required this.title,
    required this.points,
    required this.type,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_id': orderId,
      'title': title,
      'points': points,
      'type': type,
      'date': date.toIso8601String(),
    };
  }

  factory PointsHistory.fromMap(Map<String, dynamic> map) {
    return PointsHistory(
      id: map['id'] as String,
      orderId: map['order_id'] as String?,
      title: map['title'] as String,
      points: (map['points'] as num).toInt(),
      type: map['type'] as String,
      date: DateTime.parse(map['date'] as String),
    );
  }
}

class PointsState {
  final int balance;
  final List<PointsHistory> history;
  final List<PointsReward> rewards;
  final Set<String> awardedOrderIds;
  final bool isLoading;

  const PointsState({
    this.balance = 150, // Initial demo exhibition points
    this.history = const [],
    this.rewards = const [],
    this.awardedOrderIds = const {},
    this.isLoading = false,
  });

  PointsState copyWith({
    int? balance,
    List<PointsHistory>? history,
    List<PointsReward>? rewards,
    Set<String>? awardedOrderIds,
    bool? isLoading,
  }) {
    return PointsState(
      balance: balance ?? this.balance,
      history: history ?? this.history,
      rewards: rewards ?? this.rewards,
      awardedOrderIds: awardedOrderIds ?? this.awardedOrderIds,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class PointsNotifier extends StateNotifier<PointsState> {
  PointsNotifier() : super(const PointsState()) {
    _init();
  }

  static const _prefKeyBalance = 'nongki_points_balance';
  static const _prefKeyHistory = 'nongki_points_history';
  static const _prefKeyAwarded = 'nongki_points_awarded_orders';

  final List<PointsReward> _defaultRewards = const [
    PointsReward(
      id: 'rwd_1',
      title: 'Diskon Rp 5.000',
      pointsRequired: 50,
      discountFormatted: 'Rp 5.000',
      description: 'Potongan langsung untuk pembelian menu kopi apa saja.',
      category: 'Kopi',
    ),
    PointsReward(
      id: 'rwd_2',
      title: 'Gratis Extra Shot Espresso',
      pointsRequired: 35,
      discountFormatted: 'Gratis',
      description: 'Dapatkan 1 shot espresso tambahan untuk kopimu.',
      category: 'Add-on',
    ),
    PointsReward(
      id: 'rwd_3',
      title: 'Diskon 15% Pesanan Kafe',
      pointsRequired: 80,
      discountFormatted: '15% OFF',
      description: 'Diskon 15% untuk total transaksi minimal Rp 30.000.',
      category: 'Voucher',
    ),
    PointsReward(
      id: 'rwd_4',
      title: 'Voucher Cemilan Rp 10.000',
      pointsRequired: 100,
      discountFormatted: 'Rp 10.000',
      description: 'Potongan Rp 10.000 khusus menu camilan dan pastry.',
      category: 'Camilan',
    ),
    PointsReward(
      id: 'rwd_5',
      title: 'Voucher Eksklusif Nongki Rp 25.000',
      pointsRequired: 200,
      discountFormatted: 'Rp 25.000',
      description: 'Voucher pameran khusus untuk nongkrong hemat bersama teman.',
      category: 'Spesial',
    ),
  ];

  Future<void> _init() async {
    state = state.copyWith(isLoading: true, rewards: _defaultRewards);

    try {
      final prefs = await SharedPreferences.getInstance();
      final balance = prefs.getInt(_prefKeyBalance) ?? 150;
      final awardedList = prefs.getStringList(_prefKeyAwarded) ?? [];
      final historyRaw = prefs.getString(_prefKeyHistory);

      List<PointsHistory> history = [];
      if (historyRaw != null && historyRaw.isNotEmpty) {
        final decoded = jsonDecode(historyRaw) as List<dynamic>;
        history = decoded
            .map((item) => PointsHistory.fromMap(item as Map<String, dynamic>))
            .toList();
      } else {
        // Initial sample history for exhibition demonstration
        history = [
          PointsHistory(
            id: 'h_init_1',
            title: 'Bonus Pendaftaran Member NONGKI',
            points: 100,
            type: 'earn',
            date: DateTime.now().subtract(const Duration(days: 3)),
          ),
          PointsHistory(
            id: 'h_init_2',
            title: 'Poin Transaksi Ruang Temu Coffee',
            points: 50,
            type: 'earn',
            date: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ];
      }

      state = state.copyWith(
        balance: balance,
        history: history,
        awardedOrderIds: awardedList.toSet(),
        isLoading: false,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Berikan poin setelah transaksi pesanan berhasil diselesaikan
  Future<bool> awardPointsForOrder(OrderModel order) async {
    if (state.awardedOrderIds.contains(order.id)) {
      return false; // Prevent double award
    }

    // 1 poin per Rp 1.000 dari total pesanan, minimal 15 poin
    final pointsEarned = (order.total / 1000).round().clamp(15, 500);

    final newHistoryItem = PointsHistory(
      id: 'pts_${DateTime.now().millisecondsSinceEpoch}',
      orderId: order.id,
      title: 'Poin Pesanan #${order.orderNumber}',
      points: pointsEarned,
      type: 'earn',
      date: DateTime.now(),
    );

    final updatedBalance = state.balance + pointsEarned;
    final updatedHistory = [newHistoryItem, ...state.history];
    final updatedAwarded = {...state.awardedOrderIds, order.id};

    state = state.copyWith(
      balance: updatedBalance,
      history: updatedHistory,
      awardedOrderIds: updatedAwarded,
    );

    await _saveToStorage();
    return true;
  }

  /// Tukarkan poin dengan reward/voucher
  Future<String?> redeemReward(PointsReward reward) async {
    if (state.balance < reward.pointsRequired) {
      return null; // Not enough points
    }

    final newHistoryItem = PointsHistory(
      id: 'pts_rdm_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Penukaran ${reward.title}',
      points: reward.pointsRequired,
      type: 'redeem',
      date: DateTime.now(),
    );

    final updatedBalance = state.balance - reward.pointsRequired;
    final updatedHistory = [newHistoryItem, ...state.history];

    state = state.copyWith(
      balance: updatedBalance,
      history: updatedHistory,
    );

    await _saveToStorage();

    // Generate kode voucher unik untuk pameran
    final voucherCode = 'NGK-${reward.discountFormatted.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '')}-${DateTime.now().millisecond}';
    return voucherCode;
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_prefKeyBalance, state.balance);
      await prefs.setStringList(_prefKeyAwarded, state.awardedOrderIds.toList());
      final historyEncoded = jsonEncode(state.history.map((h) => h.toMap()).toList());
      await prefs.setString(_prefKeyHistory, historyEncoded);
    } catch (_) {}
  }
}

final pointsProvider = StateNotifierProvider<PointsNotifier, PointsState>((ref) {
  return PointsNotifier();
});
