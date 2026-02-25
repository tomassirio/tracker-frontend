import 'achievement_category.dart';

/// Achievement model (master definition from backend)
class Achievement {
  final String id;
  final AchievementType type;
  final String name;
  final String description;
  final int thresholdValue;

  Achievement({
    required this.id,
    required this.type,
    required this.name,
    required this.description,
    required this.thresholdValue,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
        id: json['id'] as String,
        type: AchievementType.fromJson(json['type'] as String),
        name: json['name'] as String,
        description: json['description'] as String,
        thresholdValue: json['thresholdValue'] as int,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.toJson(),
        'name': name,
        'description': description,
        'thresholdValue': thresholdValue,
      };
}
