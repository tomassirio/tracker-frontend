/// Admin-related data models

/// Statistics for trip maintenance (polyline and geocoding data)
class TripMaintenanceStats {
  final int totalTrips;
  final int tripsWithPolyline;
  final int tripsWithMultipleLocations;
  final int tripsMissingPolyline;
  final int totalUpdates;
  final int updatesWithGeocoding;
  final int updatesMissingGeocoding;

  TripMaintenanceStats({
    required this.totalTrips,
    required this.tripsWithPolyline,
    required this.tripsWithMultipleLocations,
    required this.tripsMissingPolyline,
    required this.totalUpdates,
    required this.updatesWithGeocoding,
    required this.updatesMissingGeocoding,
  });

  factory TripMaintenanceStats.fromJson(Map<String, dynamic> json) {
    return TripMaintenanceStats(
      totalTrips: json['totalTrips'] as int? ?? 0,
      tripsWithPolyline: json['tripsWithPolyline'] as int? ?? 0,
      tripsWithMultipleLocations:
          json['tripsWithMultipleLocations'] as int? ?? 0,
      tripsMissingPolyline: json['tripsMissingPolyline'] as int? ?? 0,
      totalUpdates: json['totalUpdates'] as int? ?? 0,
      updatesWithGeocoding: json['updatesWithGeocoding'] as int? ?? 0,
      updatesMissingGeocoding: json['updatesMissingGeocoding'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalTrips': totalTrips,
      'tripsWithPolyline': tripsWithPolyline,
      'tripsWithMultipleLocations': tripsWithMultipleLocations,
      'tripsMissingPolyline': tripsMissingPolyline,
      'totalUpdates': totalUpdates,
      'updatesWithGeocoding': updatesWithGeocoding,
      'updatesMissingGeocoding': updatesMissingGeocoding,
    };
  }
}
