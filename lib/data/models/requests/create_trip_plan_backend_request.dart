/// GeoLocation model matching backend structure
class GeoLocation {
  final double latitude;
  final double longitude;

  GeoLocation({
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
      };
}

/// Request model for creating a trip plan matching backend API
class CreateTripPlanBackendRequest {
  final String name;
  final String planType;
  final DateTime startDate;
  final DateTime endDate;
  final GeoLocation startLocation;
  final GeoLocation endLocation;
  final List<GeoLocation> waypoints;
  final Map<String, dynamic>? metadata;

  CreateTripPlanBackendRequest({
    required this.name,
    required this.planType,
    required this.startDate,
    required this.endDate,
    required this.startLocation,
    required this.endLocation,
    this.waypoints = const [],
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'planType': planType,
        'startDate':
            startDate.toIso8601String().split('T')[0], // LocalDate format
        'endDate': endDate.toIso8601String().split('T')[0], // LocalDate format
        'startLocation': startLocation.toJson(),
        'endLocation': endLocation.toJson(),
        'waypoints': waypoints.map((w) => w.toJson()).toList(),
        if (metadata != null) 'metadata': metadata,
      };
}
