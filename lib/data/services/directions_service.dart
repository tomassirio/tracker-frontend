import 'dart:developer' as developer;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../client/google_routes_api_client.dart';

/// Service for interacting with Google Maps Routes API
class DirectionsService {
  final GoogleRoutesApiClient _client;

  DirectionsService(String apiKey) : _client = GoogleRoutesApiClient(apiKey);

  /// Get directions between multiple waypoints using Routes API v2.
  ///
  /// First attempts to get a single route through all waypoints.
  /// If that fails, falls back to computing routes segment by segment
  /// between each pair of adjacent waypoints. Segments where no walking
  /// route is available will use a straight line between the two points.
  ///
  /// Throws if all routing attempts fail completely.
  Future<List<LatLng>> getDirections(List<LatLng> waypoints) async {
    if (waypoints.length < 2) {
      return waypoints;
    }

    // First, try to get a single route through all waypoints at once
    try {
      final result = await _client.getWalkingRoute(waypoints);
      if (result.isSuccess) {
        return result.points;
      }
    } catch (e) {
      developer.log(
        'Full route request failed, falling back to segment-by-segment: $e',
        name: 'DirectionsService',
      );
    }

    // Fall back to segment-by-segment routing
    return _getDirectionsSegmentBySegment(waypoints);
  }

  /// Computes routes segment by segment between each pair of adjacent
  /// waypoints. If a walking route cannot be found for a segment,
  /// a straight line (the two endpoints) is used for that segment.
  Future<List<LatLng>> _getDirectionsSegmentBySegment(
    List<LatLng> waypoints,
  ) async {
    final allPoints = <LatLng>[];
    bool anySegmentRouted = false;

    for (int i = 0; i < waypoints.length - 1; i++) {
      final segmentWaypoints = [waypoints[i], waypoints[i + 1]];

      try {
        final result = await _client.getWalkingRoute(segmentWaypoints);
        if (result.isSuccess) {
          // Skip the first point of subsequent segments to avoid duplicates
          if (allPoints.isNotEmpty && result.points.isNotEmpty) {
            allPoints.addAll(result.points.sublist(1));
          } else {
            allPoints.addAll(result.points);
          }
          anySegmentRouted = true;
          continue;
        }
      } catch (e) {
        developer.log(
          'Segment $i routing failed, using straight line: $e',
          name: 'DirectionsService',
        );
      }

      // Fallback: straight line for this segment
      if (allPoints.isNotEmpty) {
        allPoints.add(waypoints[i + 1]);
      } else {
        allPoints.add(waypoints[i]);
        allPoints.add(waypoints[i + 1]);
      }
    }

    if (allPoints.isEmpty) {
      throw Exception('All routing attempts failed');
    }

    if (!anySegmentRouted) {
      // No segment was successfully routed — throw so caller uses its fallback
      throw Exception('No walking routes found for any segment');
    }

    return allPoints;
  }
}
