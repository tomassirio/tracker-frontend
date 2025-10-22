import 'planned_location.dart';

/// Trip plan model
class TripPlan {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final DateTime? plannedStartDate;
  final DateTime? plannedEndDate;
  final List<PlannedLocation>? plannedLocations;
  final DateTime createdAt;
  final DateTime updatedAt;

  TripPlan({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.plannedStartDate,
    this.plannedEndDate,
    this.plannedLocations,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TripPlan.fromJson(Map<String, dynamic> json) => TripPlan(
        id: json['id'] as String,
        userId: json['userId'] as String,
        title: json['title'] as String,
        description: json['description'] as String?,
        plannedStartDate: json['plannedStartDate'] != null
            ? DateTime.parse(json['plannedStartDate'] as String)
            : null,
        plannedEndDate: json['plannedEndDate'] != null
            ? DateTime.parse(json['plannedEndDate'] as String)
            : null,
        plannedLocations: json['plannedLocations'] != null
            ? (json['plannedLocations'] as List)
                .map((loc) =>
                    PlannedLocation.fromJson(loc as Map<String, dynamic>))
                .toList()
            : null,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'title': title,
        if (description != null) 'description': description,
        if (plannedStartDate != null)
          'plannedStartDate': plannedStartDate!.toIso8601String(),
        if (plannedEndDate != null)
          'plannedEndDate': plannedEndDate!.toIso8601String(),
        if (plannedLocations != null)
          'plannedLocations':
              plannedLocations!.map((loc) => loc.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}

