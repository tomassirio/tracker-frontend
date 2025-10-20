/// Achievement model
class Achievement {
  final String id;
  final String name;
  final String description;
  final String iconUrl;
  final int requiredPoints;
  final AchievementCategory category;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.requiredPoints,
    required this.category,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        iconUrl: json['iconUrl'] as String,
        requiredPoints: json['requiredPoints'] as int,
        category: AchievementCategory.fromJson(json['category'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'iconUrl': iconUrl,
        'requiredPoints': requiredPoints,
        'category': category.toJson(),
      };
}

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

/// Achievement categories
enum AchievementCategory {
  distance,
  trips,
  social,
  exploration,
  milestone;

  String toJson() {
    switch (this) {
      case AchievementCategory.distance:
        return 'DISTANCE';
      case AchievementCategory.trips:
        return 'TRIPS';
      case AchievementCategory.social:
        return 'SOCIAL';
      case AchievementCategory.exploration:
        return 'EXPLORATION';
      case AchievementCategory.milestone:
        return 'MILESTONE';
    }
  }

  static AchievementCategory fromJson(String value) {
    switch (value.toUpperCase()) {
      case 'DISTANCE':
        return AchievementCategory.distance;
      case 'TRIPS':
        return AchievementCategory.trips;
      case 'SOCIAL':
        return AchievementCategory.social;
      case 'EXPLORATION':
        return AchievementCategory.exploration;
      case 'MILESTONE':
        return AchievementCategory.milestone;
      default:
        throw ArgumentError('Invalid achievement category: $value');
    }
  }
}
