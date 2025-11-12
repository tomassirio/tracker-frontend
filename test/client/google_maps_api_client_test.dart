import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tracker_frontend/data/client/google_maps_api_client.dart';

void main() {
  group('GoogleMapsApiClient', () {
    late GoogleMapsApiClient client;
    const apiKey = 'test-api-key';

    setUp(() {
      client = GoogleMapsApiClient(apiKey);
    });

    group('generateStaticMapUrl', () {
      test('generates basic URL with center and size', () {
        final center = const LatLng(37.7749, -122.4194);

        final url = client.generateStaticMapUrl(
          center: center,
          size: '600x450',
        );

        expect(url, contains('https://maps.googleapis.com/maps/api/staticmap'));
        expect(url, contains('center=37.7749,-122.4194'));
        expect(url, contains('size=600x450'));
        expect(url, contains('key=$apiKey'));
      });

      test('includes zoom level when provided', () {
        final center = const LatLng(37.7749, -122.4194);

        final url = client.generateStaticMapUrl(center: center, zoom: 12);

        expect(url, contains('zoom=12'));
      });

      test('includes markers when provided', () {
        final center = const LatLng(37.7749, -122.4194);
        final markers = [
          MapMarker(
            position: const LatLng(37.7749, -122.4194),
            color: 'red',
            label: 'A',
          ),
          MapMarker(
            position: const LatLng(37.7849, -122.4094),
            color: 'blue',
            label: 'B',
          ),
        ];

        final url = client.generateStaticMapUrl(
          center: center,
          markers: markers,
        );

        expect(url, contains('markers=color:red|label:A|37.7749,-122.4194'));
        expect(url, contains('markers=color:blue|label:B|37.7849,-122.4094'));
      });

      test('includes path when provided', () {
        final center = const LatLng(37.7749, -122.4194);
        final path = MapPath.encoded(
          encodedPolyline: '_p~iF~ps|U_ulLnnqC',
          color: '0x0088ffff',
          weight: 4,
        );

        final url = client.generateStaticMapUrl(center: center, path: path);

        expect(
          url,
          contains('path=color:0x0088ffff|weight:4|enc:_p~iF~ps|U_ulLnnqC'),
        );
      });

      test('handles all parameters together', () {
        final center = const LatLng(37.7749, -122.4194);
        final markers = [
          MapMarker(
            position: const LatLng(37.7749, -122.4194),
            color: 'green',
            label: 'S',
            size: 'small',
          ),
        ];
        final path = MapPath.straightLine(
          points: [
            const LatLng(37.7749, -122.4194),
            const LatLng(37.7849, -122.4094),
          ],
          color: '0xff0000ff',
          weight: 3,
        );

        final url = client.generateStaticMapUrl(
          center: center,
          size: '800x600',
          zoom: 14,
          markers: markers,
          path: path,
        );

        expect(url, contains('center=37.7749,-122.4194'));
        expect(url, contains('size=800x600'));
        expect(url, contains('zoom=14'));
        expect(url, contains('markers='));
        expect(url, contains('path='));
        expect(url, contains('key=$apiKey'));
      });
    });

    group('generateRouteMapUrl', () {
      test('generates route URL with default parameters', () {
        final startPoint = const LatLng(37.7749, -122.4194);
        final endPoint = const LatLng(37.7849, -122.4094);

        final url = client.generateRouteMapUrl(
          startPoint: startPoint,
          endPoint: endPoint,
        );

        // Center should be midpoint
        final centerLat = (37.7749 + 37.7849) / 2;
        final centerLng = (-122.4194 + -122.4094) / 2;

        expect(url, contains('center=$centerLat,$centerLng'));
        expect(url, contains('markers=color:green|label:A|37.7749,-122.4194'));
        expect(url, contains('markers=color:red|label:B|37.7849,-122.4094'));
        expect(
          url,
          contains(
            'path=color:0x0088ffff|weight:3|37.7749,-122.4194|37.7849,-122.4094',
          ),
        );
      });

      test('uses encoded polyline when provided', () {
        final startPoint = const LatLng(37.7749, -122.4194);
        final endPoint = const LatLng(37.7849, -122.4094);
        const encodedPolyline = '_p~iF~ps|U_ulLnnqC_mqNvxq`@';

        final url = client.generateRouteMapUrl(
          startPoint: startPoint,
          endPoint: endPoint,
          encodedPolyline: encodedPolyline,
        );

        expect(
          url,
          contains('path=color:0x0088ffff|weight:4|enc:$encodedPolyline'),
        );
      });

      test('respects custom colors and labels', () {
        final startPoint = const LatLng(37.7749, -122.4194);
        final endPoint = const LatLng(37.7849, -122.4094);

        final url = client.generateRouteMapUrl(
          startPoint: startPoint,
          endPoint: endPoint,
          startLabel: 'Start',
          endLabel: 'End',
          startColor: 'blue',
          endColor: 'purple',
          pathColor: '0xff00ffff',
          pathWeight: 5,
        );

        expect(
          url,
          contains('markers=color:blue|label:Start|37.7749,-122.4194'),
        );
        expect(
          url,
          contains('markers=color:purple|label:End|37.7849,-122.4094'),
        );
        expect(url, contains('color:0xff00ffff'));
      });

      test('uses custom size', () {
        final startPoint = const LatLng(37.7749, -122.4194);
        final endPoint = const LatLng(37.7849, -122.4094);

        final url = client.generateRouteMapUrl(
          startPoint: startPoint,
          endPoint: endPoint,
          size: '1024x768',
        );

        expect(url, contains('size=1024x768'));
      });
    });
  });

  group('MapMarker', () {
    test('generates URL parameter with all properties', () {
      final marker = MapMarker(
        position: const LatLng(37.7749, -122.4194),
        color: 'red',
        label: 'A',
        size: 'small',
      );

      final param = marker.toUrlParameter();

      expect(param, 'markers=color:red|label:A|size:small|37.7749,-122.4194');
    });

    test('generates URL parameter with only position', () {
      final marker = MapMarker(position: const LatLng(37.7749, -122.4194));

      final param = marker.toUrlParameter();

      expect(param, 'markers=37.7749,-122.4194');
    });

    test('generates URL parameter with color only', () {
      final marker = MapMarker(
        position: const LatLng(37.7749, -122.4194),
        color: 'blue',
      );

      final param = marker.toUrlParameter();

      expect(param, 'markers=color:blue|37.7749,-122.4194');
    });

    test('generates URL parameter with label only', () {
      final marker = MapMarker(
        position: const LatLng(37.7749, -122.4194),
        label: 'X',
      );

      final param = marker.toUrlParameter();

      expect(param, 'markers=label:X|37.7749,-122.4194');
    });
  });

  group('MapPath', () {
    group('encoded', () {
      test('generates URL parameter with encoded polyline', () {
        final path = MapPath.encoded(
          encodedPolyline: '_p~iF~ps|U_ulLnnqC',
          color: '0x0088ffff',
          weight: 4,
        );

        final param = path.toUrlParameter();

        expect(param, 'path=color:0x0088ffff|weight:4|enc:_p~iF~ps|U_ulLnnqC');
      });

      test('uses default color and weight', () {
        final path = MapPath.encoded(encodedPolyline: '_p~iF~ps|U_ulLnnqC');

        final param = path.toUrlParameter();

        expect(param, 'path=color:0x0088ffff|weight:4|enc:_p~iF~ps|U_ulLnnqC');
      });
    });

    group('straightLine', () {
      test('generates URL parameter with points', () {
        final path = MapPath.straightLine(
          points: [
            const LatLng(37.7749, -122.4194),
            const LatLng(37.7849, -122.4094),
            const LatLng(37.7949, -122.3994),
          ],
          color: '0xff0000ff',
          weight: 5,
        );

        final param = path.toUrlParameter();

        expect(
          param,
          'path=color:0xff0000ff|weight:5|37.7749,-122.4194|37.7849,-122.4094|37.7949,-122.3994',
        );
      });

      test('uses default color and weight', () {
        final path = MapPath.straightLine(
          points: [
            const LatLng(37.7749, -122.4194),
            const LatLng(37.7849, -122.4094),
          ],
        );

        final param = path.toUrlParameter();

        expect(param, contains('color:0x0088ffff'));
        expect(param, contains('weight:3'));
        expect(param, contains('37.7749,-122.4194|37.7849,-122.4094'));
      });

      test('handles empty points list', () {
        final path = MapPath.straightLine(points: []);

        final param = path.toUrlParameter();

        expect(param, '');
      });

      test('handles single point', () {
        final path = MapPath.straightLine(
          points: [const LatLng(37.7749, -122.4194)],
        );

        final param = path.toUrlParameter();

        expect(param, contains('37.7749,-122.4194'));
      });
    });
  });
}
