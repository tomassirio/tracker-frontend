import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Client for Google Routes API v2
/// Handles route computation and polyline encoding/decoding
class GoogleRoutesApiClient {
  final String _apiKey;
  final http.Client _httpClient;

  GoogleRoutesApiClient(this._apiKey, {http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  /// Get walking route between waypoints
  ///
  /// Returns a list of LatLng points representing the route.
  /// Falls back to returning the original waypoints if the API fails.
  Future<RouteResult> getWalkingRoute(List<LatLng> waypoints) async {
    return _getRoute(waypoints, travelMode: 'WALK');
  }

  /// Get driving route between waypoints
  Future<RouteResult> getDrivingRoute(List<LatLng> waypoints) async {
    return _getRoute(waypoints, travelMode: 'DRIVE');
  }

  /// Get route between waypoints with specified travel mode
  Future<RouteResult> _getRoute(
    List<LatLng> waypoints, {
    required String travelMode,
  }) async {
    if (waypoints.length < 2) {
      return RouteResult(points: waypoints);
    }

    try {
      final response = await _computeRoutes(waypoints, travelMode);
      return response;
    } catch (e) {
      // Return original waypoints as fallback
      return RouteResult(points: waypoints, error: e.toString());
    }
  }

  /// Call the Routes API v2 to compute routes
  Future<RouteResult> _computeRoutes(
    List<LatLng> waypoints,
    String travelMode,
  ) async {
    final url = Uri.parse(
      'https://routes.googleapis.com/directions/v2:computeRoutes',
    );

    // Build request body
    final requestBody = {
      'origin': {
        'location': {
          'latLng': {
            'latitude': waypoints.first.latitude,
            'longitude': waypoints.first.longitude,
          },
        },
      },
      'destination': {
        'location': {
          'latLng': {
            'latitude': waypoints.last.latitude,
            'longitude': waypoints.last.longitude,
          },
        },
      },
      'travelMode': travelMode,
      'computeAlternativeRoutes': false,
      'languageCode': 'en-US',
      'units': 'METRIC',
    };

    // Add intermediate waypoints if present
    if (waypoints.length > 2) {
      final intermediates = waypoints
          .sublist(1, waypoints.length - 1)
          .map(
            (point) => {
              'location': {
                'latLng': {
                  'latitude': point.latitude,
                  'longitude': point.longitude,
                },
              },
            },
          )
          .toList();
      requestBody['intermediates'] = intermediates;
    }

    final response = await _httpClient.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': _apiKey,
        'X-Goog-FieldMask':
            'routes.duration,routes.distanceMeters,routes.polyline.encodedPolyline',
      },
      body: json.encode(requestBody),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['routes'] != null && (data['routes'] as List).isNotEmpty) {
        final route = data['routes'][0];

        if (route['polyline'] != null &&
            route['polyline']['encodedPolyline'] != null) {
          final encodedPolyline =
              route['polyline']['encodedPolyline'] as String;
          final decodedPoints = decodePolyline(encodedPolyline);

          // Extract route metadata
          final distanceMeters = route['distanceMeters'] as int?;
          final durationString = route['duration'] as String?;

          return RouteResult(
            points: decodedPoints,
            distanceMeters: distanceMeters,
            duration: durationString,
          );
        }
      }
      throw Exception('No routes found in Routes API response');
    } else {
      throw Exception('Routes API HTTP error: ${response.statusCode}');
    }
  }

  /// Decode Google's encoded polyline format
  /// Based on the official Google algorithm
  /// https://developers.google.com/maps/documentation/utilities/polylinealgorithm
  static List<LatLng> decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0;
    int len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      // Decode latitude
      int b;
      int shift = 0;
      int result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlat = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      // Decode longitude
      shift = 0;
      result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlng = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      // Convert to double coordinates (divide by 1e5)
      // Use toSigned to ensure proper handling of negative values in Dart
      double latitude = lat.toSigned(32) / 1e5;
      double longitude = lng.toSigned(32) / 1e5;

      points.add(LatLng(latitude, longitude));
    }
    return points;
  }

  /// Encode a list of LatLng points to Google's polyline format
  static String encodePolyline(List<LatLng> points) {
    final encoded = StringBuffer();
    int prevLat = 0;
    int prevLng = 0;

    for (final point in points) {
      final lat = (point.latitude * 1e5).round();
      final lng = (point.longitude * 1e5).round();

      final dLat = lat - prevLat;
      final dLng = lng - prevLng;

      encoded.write(_encodeValue(dLat));
      encoded.write(_encodeValue(dLng));

      prevLat = lat;
      prevLng = lng;
    }

    return encoded.toString();
  }

  /// Encode a single value for polyline encoding
  static String _encodeValue(int value) {
    final encoded = StringBuffer();
    int val = value < 0 ? ~(value << 1) : (value << 1);

    while (val >= 0x20) {
      encoded.writeCharCode((0x20 | (val & 0x1f)) + 63);
      val >>= 5;
    }
    encoded.writeCharCode(val + 63);

    return encoded.toString();
  }
}

/// Result from a route computation
class RouteResult {
  final List<LatLng> points;
  final int? distanceMeters;
  final String? duration;
  final String? error;

  RouteResult({
    required this.points,
    this.distanceMeters,
    this.duration,
    this.error,
  });

  bool get hasError => error != null;
  bool get isSuccess => error == null && points.length > 1;

  double? get distanceKm =>
      distanceMeters != null ? distanceMeters! / 1000 : null;
}
