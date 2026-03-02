import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Utility class for encoding and decoding Google polyline format.
///
/// Based on the official Google algorithm:
/// https://developers.google.com/maps/documentation/utilities/polylinealgorithm
///
/// Extracted from `GoogleRoutesApiClient` so the encode/decode utilities
/// can be used without pulling in the HTTP routing client.
class PolylineCodec {
  /// Decode Google's encoded polyline format into a list of [LatLng] points.
  static List<LatLng> decode(String encoded) {
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

  /// Encode a list of [LatLng] points to Google's polyline format.
  static String encode(List<LatLng> points) {
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

  /// Encode a single value for polyline encoding.
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
