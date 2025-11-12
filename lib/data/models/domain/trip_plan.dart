/// Location model for trip plan start/end locations
class PlanLocation {
  final double lat;
  final double lon;

  PlanLocation({required this.lat, required this.lon});

  factory PlanLocation.fromJson(Map<String, dynamic> json) => PlanLocation(
    lat: (json['lat'] as num).toDouble(),
    lon: (json['lon'] as num).toDouble(),
  );

  Map<String, dynamic> toJson() => {'lat': lat, 'lon': lon};
}

/// Trip plan model matching backend TripPlanDTO
class TripPlan {
  final String id;
  final String userId;
  final String name;
  final String planType;
  final DateTime? startDate;
  final DateTime? endDate;
  final PlanLocation? startLocation;
  final PlanLocation? endLocation;
  final List<PlanLocation> waypoints;
  final DateTime createdTimestamp;

  TripPlan({
    required this.id,
    required this.userId,
    required this.name,
    required this.planType,
    this.startDate,
    this.endDate,
    this.startLocation,
    this.endLocation,
    this.waypoints = const [],
    required this.createdTimestamp,
  });

  factory TripPlan.fromJson(Map<String, dynamic> json) => TripPlan(
    id: json['id'] as String,
    userId: json['userId'] as String,
    name: json['name'] as String,
    planType: json['planType'] as String,
    startDate: json['startDate'] != null
        ? DateTime.parse(json['startDate'] as String)
        : null,
    endDate: json['endDate'] != null
        ? DateTime.parse(json['endDate'] as String)
        : null,
    startLocation: json['startLocation'] != null
        ? PlanLocation.fromJson(json['startLocation'] as Map<String, dynamic>)
        : null,
    endLocation: json['endLocation'] != null
        ? PlanLocation.fromJson(json['endLocation'] as Map<String, dynamic>)
        : null,
    waypoints: json['waypoints'] != null
        ? (json['waypoints'] as List)
              .map((loc) => PlanLocation.fromJson(loc as Map<String, dynamic>))
              .toList()
        : const [],
    createdTimestamp: DateTime.parse(json['createdTimestamp'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'name': name,
    'planType': planType,
    if (startDate != null)
      'startDate': startDate!.toIso8601String().split('T')[0],
    if (endDate != null) 'endDate': endDate!.toIso8601String().split('T')[0],
    if (startLocation != null) 'startLocation': startLocation!.toJson(),
    if (endLocation != null) 'endLocation': endLocation!.toJson(),
    'waypoints': waypoints.map((loc) => loc.toJson()).toList(),
    'createdTimestamp': createdTimestamp.toIso8601String(),
  };
}
