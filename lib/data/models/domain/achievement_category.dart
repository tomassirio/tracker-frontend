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
