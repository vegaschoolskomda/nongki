import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/review_model.dart';
import 'app_providers.dart';
import 'auth_provider.dart';
import 'order_provider.dart';

final placeReviewsProvider = FutureProvider.family<List<ReviewModel>, String>((ref, placeId) async {
  final repo = ref.watch(reviewRepositoryProvider);
  return repo.getReviews(placeId);
});

class ReviewSubmitter {
  final Ref _ref;

  ReviewSubmitter(this._ref);

  Future<void> submit({
    required String placeId,
    required double rating,
    required String comment,
    String? orderId,
  }) async {
    final user = _ref.read(authProvider).user;
    if (user == null) {
      throw Exception('Harap login terlebih dahulu untuk memberikan ulasan');
    }

    final newReview = ReviewModel(
      id: 'rev_${DateTime.now().millisecondsSinceEpoch}',
      placeId: placeId,
      userId: user.id,
      userName: user.name,
      userAvatar: user.avatarUrl,
      orderId: orderId,
      rating: rating,
      comment: comment,
      createdAt: DateTime.now(),
    );

    await _ref.read(reviewRepositoryProvider).submitReview(newReview);

    if (orderId != null) {
      _ref.read(orderProvider.notifier).markOrderAsReviewed(orderId);
    }

    // Invalidate reviews cache for this place
    _ref.invalidate(placeReviewsProvider(placeId));
  }
}

final reviewSubmitterProvider = Provider<ReviewSubmitter>((ref) {
  return ReviewSubmitter(ref);
});

