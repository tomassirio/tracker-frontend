import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:wanderer_frontend/data/client/polyline_codec.dart';

void main() {
  group('PolylineCodec', () {
    group('decode', () {
      test('decodes a known encoded polyline', () {
        // Standard Google polyline example
        const encoded = '_p~iF~ps|U_ulLnnqC_mqNvxq`@';
        final points = PolylineCodec.decode(encoded);

        expect(points.length, 3);
        expect(points[0].latitude, closeTo(38.5, 0.01));
        expect(points[0].longitude, closeTo(-120.2, 0.01));
        expect(points[1].latitude, closeTo(40.7, 0.01));
        expect(points[1].longitude, closeTo(-120.95, 0.01));
        expect(points[2].latitude, closeTo(43.252, 0.01));
        expect(points[2].longitude, closeTo(-126.453, 0.01));
      });

      test('decodes empty string to empty list', () {
        final points = PolylineCodec.decode('');
        expect(points, isEmpty);
      });

      test('decodes single point polyline', () {
        // Encode a single point and verify round-trip
        const point = LatLng(37.7749, -122.4194);
        final encoded = PolylineCodec.encode([point]);
        final decoded = PolylineCodec.decode(encoded);

        expect(decoded.length, 1);
        expect(decoded[0].latitude, closeTo(37.7749, 0.001));
        expect(decoded[0].longitude, closeTo(-122.4194, 0.001));
      });
    });

    group('encode', () {
      test('encodes a list of points', () {
        final points = [
          const LatLng(38.5, -120.2),
          const LatLng(40.7, -120.95),
          const LatLng(43.252, -126.453),
        ];
        final encoded = PolylineCodec.encode(points);

        expect(encoded, isNotEmpty);
        expect(encoded, isA<String>());
      });

      test('encodes empty list to empty string', () {
        final encoded = PolylineCodec.encode([]);
        expect(encoded, '');
      });

      test('encodes two points', () {
        final points = [
          const LatLng(37.7749, -122.4194),
          const LatLng(37.7849, -122.4094),
        ];
        final encoded = PolylineCodec.encode(points);
        expect(encoded, isNotEmpty);
      });
    });

    group('round-trip encode/decode', () {
      test('encode then decode preserves points', () {
        final original = [
          const LatLng(37.7749, -122.4194),
          const LatLng(34.0522, -118.2437),
          const LatLng(36.7783, -119.4179),
        ];

        final encoded = PolylineCodec.encode(original);
        final decoded = PolylineCodec.decode(encoded);

        expect(decoded.length, original.length);
        for (int i = 0; i < original.length; i++) {
          // Polyline encoding has ~1e-5 precision
          expect(decoded[i].latitude, closeTo(original[i].latitude, 0.001));
          expect(decoded[i].longitude, closeTo(original[i].longitude, 0.001));
        }
      });

      test('round-trip preserves negative coordinates', () {
        final original = [
          const LatLng(-33.8688, 151.2093), // Sydney
          const LatLng(-37.8136, 144.9631), // Melbourne
        ];

        final encoded = PolylineCodec.encode(original);
        final decoded = PolylineCodec.decode(encoded);

        expect(decoded.length, 2);
        expect(decoded[0].latitude, closeTo(-33.8688, 0.001));
        expect(decoded[0].longitude, closeTo(151.2093, 0.001));
        expect(decoded[1].latitude, closeTo(-37.8136, 0.001));
        expect(decoded[1].longitude, closeTo(144.9631, 0.001));
      });

      test('round-trip preserves many points', () {
        final original = List.generate(
          50,
          (i) => LatLng(37.0 + i * 0.1, -122.0 + i * 0.05),
        );

        final encoded = PolylineCodec.encode(original);
        final decoded = PolylineCodec.decode(encoded);

        expect(decoded.length, original.length);
        for (int i = 0; i < original.length; i++) {
          expect(decoded[i].latitude, closeTo(original[i].latitude, 0.001));
          expect(decoded[i].longitude, closeTo(original[i].longitude, 0.001));
        }
      });
    });
  });
}
