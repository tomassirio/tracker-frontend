import '../domain/planned_location.dart';

/// Request model for creating a trip plan
class CreateTripPlanRequest {
  final String name;
  final String? description;
  final DateTime? plannedStartDate;
  final DateTime? plannedEndDate;
  final List<PlannedLocation>? plannedLocations;

  CreateTripPlanRequest({
    required this.name,
    this.description,
    this.plannedStartDate,
    this.plannedEndDate,
    this.plannedLocations,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    if (description != null) 'description': description,
    if (plannedStartDate != null)
      'plannedStartDate': plannedStartDate!.toIso8601String(),
    if (plannedEndDate != null)
      'plannedEndDate': plannedEndDate!.toIso8601String(),
    if (plannedLocations != null)
      'plannedLocations': plannedLocations!.map((loc) => loc.toJson()).toList(),
  };
}
