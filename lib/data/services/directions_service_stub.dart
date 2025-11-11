// Stub implementation for non-web platforms
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DirectionsServiceWeb {
  Future<List<LatLng>> getDirections(List<LatLng> waypoints) async {
    throw UnsupportedError('DirectionsServiceWeb is only available on web');
  }
}
