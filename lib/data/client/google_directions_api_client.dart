import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import 'polyline_codec.dart';

/// Client for Google Directions API.
///
/// Computes a road-snapped encoded polyline from an ordered list of waypoints.
/// Uses the Directions API: https://developers.google.com/maps/documentation/directions
class GoogleDirectionsApiClient {
  final String _apiKey;
  final http.Client _httpClient;

  static const String _baseUrl =
      'https://maps.googleapis.com/maps/api/directions/json';

  /// Maximum number of waypoints the Directions API accepts (excluding
  /// origin and destination).
  static const int maxWaypoints = 25;

  GoogleDirectionsApiClient(
    this._apiKey, {
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  /// Computes a road-snapped encoded polyline for the given ordered points.
  ///
  /// [points] must contain at least 2 entries: the first is the origin,
  /// the last is the destination, and any entries in between become
  /// intermediate waypoints.
  ///
  /// Returns the encoded polyline string on success, or `null` if the
  /// request fails or the API returns no routes.
  Future<String?> getRoutePolyline(List<LatLng> points) async {
    if (points.length < 2) return null;

    final origin = points.first;
    final destination = points.last;
    final intermediates =
        points.length > 2 ? points.sublist(1, points.length - 1) : <LatLng>[];

    // Truncate intermediate waypoints to API limit
    final waypointList = intermediates.length > maxWaypoints
        ? intermediates.sublist(0, maxWaypoints)
        : intermediates;

    final queryParams = <String, String>{
      'origin': '${origin.latitude},${origin.longitude}',
      'destination': '${destination.latitude},${destination.longitude}',
      'key': _apiKey,
      'mode': 'walking',
    };

    if (waypointList.isNotEmpty) {
      queryParams['waypoints'] =
          waypointList.map((w) => '${w.latitude},${w.longitude}').join('|');
    }

    final uri = Uri.parse(_baseUrl).replace(queryParameters: queryParams);

    try {
      final response = await _httpClient.get(uri);

      if (response.statusCode != 200) {
        debugPrint(
          'GoogleDirectionsApiClient: HTTP ${response.statusCode} '
          'for directions request',
        );
        return null;
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final status = json['status'] as String?;

      if (status != 'OK') {
        debugPrint(
          'GoogleDirectionsApiClient: Directions API status: $status',
        );
        return null;
      }

      final routes = json['routes'] as List<dynamic>?;
      if (routes == null || routes.isEmpty) return null;

      final overviewPolyline =
          routes[0]['overview_polyline'] as Map<String, dynamic>?;
      if (overviewPolyline == null) return null;

      final encoded = overviewPolyline['points'] as String?;
      return (encoded != null && encoded.isNotEmpty) ? encoded : null;
    } catch (e) {
      debugPrint('GoogleDirectionsApiClient: Error fetching route: $e');
      return null;
    }
  }

  /// Computes a road-snapped encoded polyline and also returns the decoded
  /// [LatLng] points for immediate map rendering.
  ///
  /// Returns `null` if the request fails.
  Future<DirectionsResult?> getRouteWithPoints(List<LatLng> points) async {
    final encoded = await getRoutePolyline(points);
    if (encoded == null) return null;

    final decoded = PolylineCodec.decode(encoded);
    return DirectionsResult(
      encodedPolyline: encoded,
      routePoints: decoded,
    );
  }

  /// Disposes the underlying HTTP client.
  void dispose() {
    _httpClient.close();
  }
}

/// Result of a Directions API call containing both the encoded polyline
/// string (for storage/backend) and the decoded route points (for map
/// rendering).
class DirectionsResult {
  final String encodedPolyline;
  final List<LatLng> routePoints;

  const DirectionsResult({
    required this.encodedPolyline,
    required this.routePoints,
  });
}
