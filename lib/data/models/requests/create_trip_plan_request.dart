import '../domain/planned_location.dart';

/// Request model for creating a trip plan
class CreateTripPlanRequest {
  final String title;
  final String? description;
  final DateTime? plannedStartDate;
  final DateTime? plannedEndDate;
  final List<PlannedLocation>? plannedLocations;

  CreateTripPlanRequest({
    required this.title,
    this.description,
    this.plannedStartDate,
    this.plannedEndDate,
    this.plannedLocations,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        if (description != null) 'description': description,
        if (plannedStartDate != null)
          'plannedStartDate': plannedStartDate!.toIso8601String(),
        if (plannedEndDate != null)
          'plannedEndDate': plannedEndDate!.toIso8601String(),
        if (plannedLocations != null)
          'plannedLocations':
              plannedLocations!.map((loc) => loc.toJson()).toList(),
      };
}

