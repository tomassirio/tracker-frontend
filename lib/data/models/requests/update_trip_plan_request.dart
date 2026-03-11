import '../domain/planned_location.dart';
import '../domain/trip_plan.dart';

/// Request model for updating a trip plan
class UpdateTripPlanRequest {
  final String? name;
  final String? description;
  final DateTime? plannedStartDate;
  final DateTime? plannedEndDate;
  final DateTime? startDate;
  final DateTime? endDate;
  final PlanLocation? startLocation;
  final PlanLocation? endLocation;
  final List<PlannedLocation>? plannedLocations;
  final List<PlanLocation>? waypoints;
  final String? plannedPolyline;

  UpdateTripPlanRequest({
    this.name,
    this.description,
    this.plannedStartDate,
    this.plannedEndDate,
    this.startDate,
    this.endDate,
    this.startLocation,
    this.endLocation,
    this.plannedLocations,
    this.waypoints,
    this.plannedPolyline,
  });

  Map<String, dynamic> toJson() => {
        if (name != null) 'name': name,
        if (description != null) 'description': description,
        if (plannedStartDate != null)
          'plannedStartDate': plannedStartDate!.toIso8601String(),
        if (plannedEndDate != null)
          'plannedEndDate': plannedEndDate!.toIso8601String(),
        if (startDate != null)
          'startDate': startDate!.toIso8601String().split('T')[0],
        if (endDate != null)
          'endDate': endDate!.toIso8601String().split('T')[0],
        if (startLocation != null) 'startLocation': startLocation!.toJson(),
        if (endLocation != null) 'endLocation': endLocation!.toJson(),
        if (plannedLocations != null)
          'plannedLocations':
              plannedLocations!.map((loc) => loc.toJson()).toList(),
        if (waypoints != null)
          'waypoints': waypoints!.map((loc) => loc.toJson()).toList(),
        if (plannedPolyline != null) 'plannedPolyline': plannedPolyline,
      };
}
