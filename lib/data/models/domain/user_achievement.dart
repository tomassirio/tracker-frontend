import 'achievement.dart';

/// User achievement model (achievement unlocked by user)
class UserAchievement {
  final String id;
  final String userId;
  final Achievement achievement;
  final DateTime unlockedAt;

  UserAchievement({
    required this.id,
    required this.userId,
    required this.achievement,
    required this.unlockedAt,
  });

  factory UserAchievement.fromJson(Map<String, dynamic> json) =>
      UserAchievement(
        id: json['id'] as String,
        userId: json['userId'] as String,
        achievement:
            Achievement.fromJson(json['achievement'] as Map<String, dynamic>),
        unlockedAt: DateTime.parse(json['unlockedAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'achievement': achievement.toJson(),
        'unlockedAt': unlockedAt.toIso8601String(),
      };
}

