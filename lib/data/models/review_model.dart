import 'package:equatable/equatable.dart';

class ReviewModel extends Equatable {
  final String id;
  final String placeId;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String? orderId;
  final double rating;
  final String comment;
  final DateTime createdAt;

  const ReviewModel({
    required this.id,
    required this.placeId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    this.orderId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      id: map['id'] as String,
      placeId: map['place_id'] as String,
      userId: map['user_id'] as String,
      userName: map['user_name'] as String? ?? 'Pengguna Nongki',
      userAvatar: map['user_avatar'] as String?,
      orderId: map['order_id'] as String?,
      rating: (map['rating'] as num).toDouble(),
      comment: map['comment'] as String? ?? '',
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'place_id': placeId,
      'user_id': userId,
      'user_name': userName,
      'user_avatar': userAvatar,
      'order_id': orderId,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, placeId, userId, rating, comment];
}

