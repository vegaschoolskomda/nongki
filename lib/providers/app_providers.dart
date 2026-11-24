import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/place_repository.dart';
import '../data/repositories/order_repository.dart';
import '../data/repositories/review_repository.dart';

// Repository singletons
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return HybridAuthRepository();
});

final placeRepositoryProvider = Provider<PlaceRepository>((ref) {
  return HybridPlaceRepository();
});

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return HybridOrderRepository();
});

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  return HybridReviewRepository();
});
