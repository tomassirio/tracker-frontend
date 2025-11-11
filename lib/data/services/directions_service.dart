import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/foundation.dart';
import '../client/google_routes_api_client.dart';

/// Service for interacting with Google Maps Routes API
class DirectionsService {
  final GoogleRoutesApiClient _client;

  DirectionsService(String apiKey) : _client = GoogleRoutesApiClient(apiKey);

  /// Get directions between multiple waypoints using Routes API v2
  Future<List<LatLng>> getDirections(List<LatLng> waypoints) async {
    if (waypoints.length < 2) {
      return waypoints;
    }

    try {
      final result = await _client.getWalkingRoute(waypoints);

      if (result.isSuccess) {
        return result.points;
      } else {
        return waypoints;
      }
    } catch (e) {
      debugPrint(
        '💥 DirectionsService failed: $e, falling back to straight lines',
      );
      return waypoints;
    }
  }
}
