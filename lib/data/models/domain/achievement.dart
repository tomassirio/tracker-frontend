import 'achievement_category.dart';

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

