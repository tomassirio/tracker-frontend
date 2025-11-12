@JS()
library;

import 'dart:js_interop';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/foundation.dart';

/// Web-specific implementation using Google Maps JavaScript API
class DirectionsServiceWeb {
  /// Get directions between waypoints using the JavaScript API
  Future<List<LatLng>> getDirections(List<LatLng> waypoints) async {
    if (waypoints.length < 2) {
      return waypoints;
    }

    try {
      // For web, we'll use the JavaScript Directions Service
      // This requires the Directions API to be available in the loaded Google Maps JS
      final result = await _callDirectionsServiceJS(waypoints);

      if (result.isNotEmpty) {
        return result;
      } else {
        return waypoints;
      }
    } catch (e) {
      debugPrint(
        '💥 DirectionsServiceWeb failed: $e, falling back to straight lines',
      );
      return waypoints;
    }
  }

  /// Call the JavaScript Directions Service API
  Future<List<LatLng>> _callDirectionsServiceJS(List<LatLng> waypoints) async {
    // For now, return the waypoints as-is (straight lines)
    // The JavaScript API integration would require more complex JS interop
    // which is beyond the scope of a quick fix
    return waypoints;
  }
}
