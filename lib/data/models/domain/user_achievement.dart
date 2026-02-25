import 'achievement.dart';

/// User achievement model (achievement unlocked by user)
class UserAchievement {
  final String id;
  final String userId;
  final Achievement achievement;
  final String? tripId;
  final DateTime unlockedAt;
  final double valueAchieved;

  UserAchievement({
    required this.id,
    required this.userId,
    required this.achievement,
    this.tripId,
    required this.unlockedAt,
    required this.valueAchieved,
  });

  factory UserAchievement.fromJson(Map<String, dynamic> json) =>
      UserAchievement(
        id: json['id'] as String,
        userId: json['userId'] as String,
        achievement: Achievement.fromJson(
          json['achievement'] as Map<String, dynamic>,
        ),
        tripId: json['tripId'] as String?,
        unlockedAt: DateTime.parse(json['unlockedAt'] as String),
        valueAchieved: (json['valueAchieved'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'achievement': achievement.toJson(),
        'tripId': tripId,
        'unlockedAt': unlockedAt.toIso8601String(),
        'valueAchieved': valueAchieved,
      };
}
