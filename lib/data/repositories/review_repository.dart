import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/review_model.dart';
import '../mock/mock_data.dart';

abstract class ReviewRepository {
  Future<List<ReviewModel>> getReviews(String placeId);
  Future<ReviewModel> submitReview(ReviewModel review);
}

class MockReviewRepository implements ReviewRepository {
  final List<ReviewModel> _reviews = List.from(MockData.reviews);

  @override
  Future<List<ReviewModel>> getReviews(String placeId) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final list = _reviews.where((r) => r.placeId == placeId).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  @override
  Future<ReviewModel> submitReview(ReviewModel review) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (review.rating < 1 || review.rating > 5) {
      throw Exception('Rating harus antara 1 sampai 5 bintang');
    }
    if (review.comment.trim().isEmpty) {
      throw Exception('Cerita pengalaman nongkrong tidak boleh kosong');
    }
    _reviews.insert(0, review);
    return review;
  }
}

/// Hybrid Review Repository: loads & posts reviews to Supabase Cloud, falls back to Mock
class HybridReviewRepository implements ReviewRepository {
  final MockReviewRepository _local = MockReviewRepository();

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
  Future<List<ReviewModel>> getReviews(String placeId) async {
    final localList = await _local.getReviews(placeId);
    if (_isSupabaseConfigured) {
      try {
        final client = Supabase.instance.client;
        final decoded = Uri.decodeComponent(placeId).trim();
        final clean = decoded.replaceAll('/', '_');
        final raw = decoded.replaceAll('_', '/');

        final res = await client
            .from('reviews')
            .select()
            .or('place_id.eq.$placeId,place_id.eq.$clean,place_id.eq.$raw')
            .order('created_at', ascending: false);

        final remote = (res as List).map((r) => ReviewModel.fromMap(r)).toList();
        if (remote.isNotEmpty) {
          final merged = List<ReviewModel>.from(localList);
          for (final r in remote) {
            if (!merged.any((l) => l.id == r.id)) merged.insert(0, r);
          }
          merged.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return merged;
        }
      } catch (e) {
        debugPrint('[ReviewRepository] Error fetching reviews from Supabase: $e');
      }
    }
    return localList;
  }

  @override
  Future<ReviewModel> submitReview(ReviewModel review) async {
    final saved = await _local.submitReview(review);
    if (_isSupabaseConfigured) {
      try {
        final client = Supabase.instance.client;
        await client.from('reviews').insert(review.toMap());
      } catch (e) {
        debugPrint('[ReviewRepository] Error inserting review to Supabase: $e');
      }
    }
    return saved;
  }
}

