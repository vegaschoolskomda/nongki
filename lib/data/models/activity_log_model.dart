import 'package:equatable/equatable.dart';

class ActivityLogModel extends Equatable {
  final String id;
  final String action;
  final String actorName;
  final String actorRole;
  final String details;
  final DateTime timestamp;

  const ActivityLogModel({
    required this.id,
    required this.action,
    required this.actorName,
    required this.actorRole,
    required this.details,
    required this.timestamp,
  });

  factory ActivityLogModel.fromMap(Map<String, dynamic> map) {
    return ActivityLogModel(
      id: map['id']?.toString() ?? '',
      action: map['action']?.toString() ?? '',
      actorName: map['actor_name']?.toString() ?? 'Sistem',
      actorRole: map['actor_role']?.toString() ?? 'system',
      details: map['details']?.toString() ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'action': action,
      'actor_name': actorName,
      'actor_role': actorRole,
      'details': details,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, action, actorName, actorRole, timestamp];
}
