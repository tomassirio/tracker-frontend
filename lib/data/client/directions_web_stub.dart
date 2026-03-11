import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Stub implementation for non-web platforms.
/// Returns `null` so the caller falls back to the HTTP-based Directions API.
Future<String?> getDirectionsPolylineWeb(
  List<LatLng> points,
  String apiKey,
) async {
  return null;
}
