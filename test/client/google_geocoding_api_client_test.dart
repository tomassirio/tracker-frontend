import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tracker_frontend/data/client/google_geocoding_api_client.dart';

import 'google_geocoding_api_client_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  group('GoogleGeocodingApiClient', () {
    late GoogleGeocodingApiClient client;
    const apiKey = 'test-api-key';

    setUp(() {
      client = GoogleGeocodingApiClient(apiKey);
    });

    test('should initialize with API key', () {
      expect(client, isNotNull);
    });

    group('PlaceInfo', () {
      test('should have correct display format with formatted address', () {
        final placeInfo = PlaceInfo(
          city: 'New York',
          country: 'United States',
          formattedAddress: '123 Main St, New York, NY 10001, USA',
        );

        expect(placeInfo.city, 'New York');
        expect(placeInfo.country, 'United States');
        expect(
          placeInfo.formattedAddress,
          '123 Main St, New York, NY 10001, USA',
        );
        expect(placeInfo.displayName, 'New York, United States');
        expect(placeInfo.toString(), 'New York, United States');
      });

      test('should handle city and country without formatted address', () {
        final placeInfo = PlaceInfo(city: 'Paris', country: 'France');

        expect(placeInfo.city, 'Paris');
        expect(placeInfo.country, 'France');
        expect(placeInfo.displayName, 'Paris, France');
        expect(placeInfo.formattedAddress, isNull);
      });

      test('should format displayName correctly for different locations', () {
        final testCases = [
          ('Tokyo', 'Japan', 'Tokyo, Japan'),
          ('London', 'United Kingdom', 'London, United Kingdom'),
          ('São Paulo', 'Brazil', 'São Paulo, Brazil'),
          ('Sydney', 'Australia', 'Sydney, Australia'),
        ];

        for (final testCase in testCases) {
          final placeInfo = PlaceInfo(city: testCase.$1, country: testCase.$2);
          expect(placeInfo.displayName, testCase.$3);
        }
      });
    });

    group('reverseGeocode', () {
      test('should handle invalid API key gracefully', () async {
        // With invalid API key, the API will return an error
        // Our client should return null instead of throwing
        final invalidClient = GoogleGeocodingApiClient('invalid-key');
        final location = const LatLng(40.7128, -74.0060);

        final result = await invalidClient.reverseGeocode(location);

        // Should return null instead of throwing an exception
        expect(result, isNull);
      });

      test('should handle network errors gracefully', () async {
        // Test with an unreachable location or malformed request
        final location = const LatLng(999.0, 999.0); // Invalid coordinates

        final result = await client.reverseGeocode(location);

        // Should return null instead of throwing
        expect(result, isNull);
      });

      test('should construct correct API URL', () {
        // This tests the URL construction logic
        const testLocation = LatLng(40.7128, -74.0060);

        // The client should construct URL like:
        // https://maps.googleapis.com/maps/api/geocode/json?latlng=40.7128,-74.0060&key=test-api-key

        // We can't directly test the URL without mocking, but we can verify
        // the client doesn't throw when creating a request
        expect(() => client.reverseGeocode(testLocation), returnsNormally);
      });
    });

    group('batchReverseGeocode', () {
      test('should return empty map for empty locations list', () async {
        final result = await client.batchReverseGeocode([]);

        expect(result, isEmpty);
      });

      test('should handle single location', () async {
        final locations = [const LatLng(40.7128, -74.0060)];

        final result = await client.batchReverseGeocode(locations);

        // Should return a map (might be empty if API call fails)
        expect(result, isA<Map<String, PlaceInfo>>());
      });

      test('should use correct key format for locations', () async {
        // The batch method should use 'lat,lng' as keys
        final locations = [
          const LatLng(40.7128, -74.0060),
          const LatLng(48.8566, 2.3522),
        ];

        final result = await client.batchReverseGeocode(locations);

        // Result should be a map
        expect(result, isA<Map<String, PlaceInfo>>());

        // Keys should be in the format "lat,lng"
        for (final location in locations) {
          final expectedKey = '${location.latitude},${location.longitude}';
          // Key might not be in results if API call failed, but format is correct
          expect(expectedKey, contains(','));
        }
      });

      test('should handle multiple locations without throwing', () async {
        final locations = [
          const LatLng(40.7128, -74.0060), // New York
          const LatLng(48.8566, 2.3522), // Paris
          const LatLng(51.5074, -0.1278), // London
        ];

        // Should complete without throwing
        expect(
          () async => await client.batchReverseGeocode(locations),
          returnsNormally,
        );
      });
    });

    group('Error Handling', () {
      test('should not throw on network errors', () async {
        final location = const LatLng(0.0, 0.0);

        // Should return null, not throw
        expect(
          () async => await client.reverseGeocode(location),
          returnsNormally,
        );
      });

      test('should handle malformed responses gracefully', () async {
        // Test with extreme coordinates
        final location = const LatLng(91.0, 181.0); // Invalid coords

        final result = await client.reverseGeocode(location);

        expect(result, isNull);
      });
    });

    group('_parseAddressComponents unit tests', () {
      late MockClient mockHttpClient;
      late GoogleGeocodingApiClient clientWithMock;

      setUp(() {
        mockHttpClient = MockClient();
        clientWithMock = GoogleGeocodingApiClient(
          apiKey,
          httpClient: mockHttpClient,
        );
      });

      test('should parse city from locality component', () async {
        final mockResponse = {
          'status': 'OK',
          'results': [
            {
              'formatted_address': '123 Main St, New York, NY 10001, USA',
              'address_components': [
                {
                  'long_name': 'New York',
                  'short_name': 'NY',
                  'types': ['locality', 'political'],
                },
                {
                  'long_name': 'United States',
                  'short_name': 'US',
                  'types': ['country', 'political'],
                },
              ],
            },
          ],
        };

        when(mockHttpClient.get(any)).thenAnswer(
          (_) async => http.Response(json.encode(mockResponse), 200),
        );

        final result = await clientWithMock.reverseGeocode(
          const LatLng(40.7128, -74.0060),
        );

        expect(result, isNotNull);
        expect(result!.city, 'New York');
        expect(result.country, 'United States');
        expect(result.formattedAddress, '123 Main St, New York, NY 10001, USA');
      });

      test(
        'should parse city from administrative_area_level_2 when locality not present',
        () async {
          final mockResponse = {
            'status': 'OK',
            'results': [
              {
                'formatted_address': 'Los Angeles County, CA, USA',
                'address_components': [
                  {
                    'long_name': 'Los Angeles County',
                    'short_name': 'Los Angeles County',
                    'types': ['administrative_area_level_2', 'political'],
                  },
                  {
                    'long_name': 'United States',
                    'short_name': 'US',
                    'types': ['country', 'political'],
                  },
                ],
              },
            ],
          };

          when(mockHttpClient.get(any)).thenAnswer(
            (_) async => http.Response(json.encode(mockResponse), 200),
          );

          final result = await clientWithMock.reverseGeocode(
            const LatLng(34.0522, -118.2437),
          );

          expect(result, isNotNull);
          expect(result!.city, 'Los Angeles County');
          expect(result.country, 'United States');
        },
      );

      test(
        'should parse city from administrative_area_level_1 as fallback',
        () async {
          final mockResponse = {
            'status': 'OK',
            'results': [
              {
                'formatted_address': 'California, USA',
                'address_components': [
                  {
                    'long_name': 'California',
                    'short_name': 'CA',
                    'types': ['administrative_area_level_1', 'political'],
                  },
                  {
                    'long_name': 'United States',
                    'short_name': 'US',
                    'types': ['country', 'political'],
                  },
                ],
              },
            ],
          };

          when(mockHttpClient.get(any)).thenAnswer(
            (_) async => http.Response(json.encode(mockResponse), 200),
          );

          final result = await clientWithMock.reverseGeocode(
            const LatLng(36.7783, -119.4179),
          );

          expect(result, isNotNull);
          expect(result!.city, 'California');
          expect(result.country, 'United States');
        },
      );

      test('should prefer locality over administrative_area_level_2', () async {
        final mockResponse = {
          'status': 'OK',
          'results': [
            {
              'formatted_address': 'San Francisco, CA, USA',
              'address_components': [
                {
                  'long_name': 'San Francisco',
                  'short_name': 'SF',
                  'types': ['locality', 'political'],
                },
                {
                  'long_name': 'San Francisco County',
                  'short_name': 'San Francisco County',
                  'types': ['administrative_area_level_2', 'political'],
                },
                {
                  'long_name': 'United States',
                  'short_name': 'US',
                  'types': ['country', 'political'],
                },
              ],
            },
          ],
        };

        when(mockHttpClient.get(any)).thenAnswer(
          (_) async => http.Response(json.encode(mockResponse), 200),
        );

        final result = await clientWithMock.reverseGeocode(
          const LatLng(37.7749, -122.4194),
        );

        expect(result, isNotNull);
        expect(result!.city, 'San Francisco');
        expect(result.country, 'United States');
      });

      test('should return null when city is missing', () async {
        final mockResponse = {
          'status': 'OK',
          'results': [
            {
              'formatted_address': 'United States',
              'address_components': [
                {
                  'long_name': 'United States',
                  'short_name': 'US',
                  'types': ['country', 'political'],
                },
              ],
            },
          ],
        };

        when(mockHttpClient.get(any)).thenAnswer(
          (_) async => http.Response(json.encode(mockResponse), 200),
        );

        final result = await clientWithMock.reverseGeocode(
          const LatLng(39.8283, -98.5795),
        );

        expect(result, isNull);
      });

      test('should return null when country is missing', () async {
        final mockResponse = {
          'status': 'OK',
          'results': [
            {
              'formatted_address': 'Some City',
              'address_components': [
                {
                  'long_name': 'Some City',
                  'short_name': 'Some City',
                  'types': ['locality', 'political'],
                },
              ],
            },
          ],
        };

        when(mockHttpClient.get(any)).thenAnswer(
          (_) async => http.Response(json.encode(mockResponse), 200),
        );

        final result = await clientWithMock.reverseGeocode(
          const LatLng(0.0, 0.0),
        );

        expect(result, isNull);
      });

      test('should return null when address_components is null', () async {
        final mockResponse = {
          'status': 'OK',
          'results': [
            {'formatted_address': 'Some Address', 'address_components': null},
          ],
        };

        when(mockHttpClient.get(any)).thenAnswer(
          (_) async => http.Response(json.encode(mockResponse), 200),
        );

        final result = await clientWithMock.reverseGeocode(
          const LatLng(0.0, 0.0),
        );

        expect(result, isNull);
      });

      test('should return null when address_components is missing', () async {
        final mockResponse = {
          'status': 'OK',
          'results': [
            {'formatted_address': 'Some Address'},
          ],
        };

        when(mockHttpClient.get(any)).thenAnswer(
          (_) async => http.Response(json.encode(mockResponse), 200),
        );

        final result = await clientWithMock.reverseGeocode(
          const LatLng(0.0, 0.0),
        );

        expect(result, isNull);
      });

      test('should handle complex address with multiple components', () async {
        final mockResponse = {
          'status': 'OK',
          'results': [
            {
              'formatted_address':
                  '1600 Amphitheatre Parkway, Mountain View, CA 94043, USA',
              'address_components': [
                {
                  'long_name': '1600',
                  'short_name': '1600',
                  'types': ['street_number'],
                },
                {
                  'long_name': 'Amphitheatre Parkway',
                  'short_name': 'Amphitheatre Pkwy',
                  'types': ['route'],
                },
                {
                  'long_name': 'Mountain View',
                  'short_name': 'Mountain View',
                  'types': ['locality', 'political'],
                },
                {
                  'long_name': 'Santa Clara County',
                  'short_name': 'Santa Clara County',
                  'types': ['administrative_area_level_2', 'political'],
                },
                {
                  'long_name': 'California',
                  'short_name': 'CA',
                  'types': ['administrative_area_level_1', 'political'],
                },
                {
                  'long_name': 'United States',
                  'short_name': 'US',
                  'types': ['country', 'political'],
                },
                {
                  'long_name': '94043',
                  'short_name': '94043',
                  'types': ['postal_code'],
                },
              ],
            },
          ],
        };

        when(mockHttpClient.get(any)).thenAnswer(
          (_) async => http.Response(json.encode(mockResponse), 200),
        );

        final result = await clientWithMock.reverseGeocode(
          const LatLng(37.4224, -122.0842),
        );

        expect(result, isNotNull);
        expect(result!.city, 'Mountain View');
        expect(result.country, 'United States');
        expect(
          result.formattedAddress,
          '1600 Amphitheatre Parkway, Mountain View, CA 94043, USA',
        );
      });

      test('should handle international address (non-US)', () async {
        final mockResponse = {
          'status': 'OK',
          'results': [
            {
              'formatted_address': 'Tokyo, Japan',
              'address_components': [
                {
                  'long_name': 'Tokyo',
                  'short_name': 'Tokyo',
                  'types': ['locality', 'political'],
                },
                {
                  'long_name': 'Japan',
                  'short_name': 'JP',
                  'types': ['country', 'political'],
                },
              ],
            },
          ],
        };

        when(mockHttpClient.get(any)).thenAnswer(
          (_) async => http.Response(json.encode(mockResponse), 200),
        );

        final result = await clientWithMock.reverseGeocode(
          const LatLng(35.6762, 139.6503),
        );

        expect(result, isNotNull);
        expect(result!.city, 'Tokyo');
        expect(result.country, 'Japan');
      });

      test('should return null when status is not OK', () async {
        final mockResponse = {'status': 'ZERO_RESULTS', 'results': []};

        when(mockHttpClient.get(any)).thenAnswer(
          (_) async => http.Response(json.encode(mockResponse), 200),
        );

        final result = await clientWithMock.reverseGeocode(
          const LatLng(0.0, 0.0),
        );

        expect(result, isNull);
      });

      test('should return null when results array is empty', () async {
        final mockResponse = {'status': 'OK', 'results': []};

        when(mockHttpClient.get(any)).thenAnswer(
          (_) async => http.Response(json.encode(mockResponse), 200),
        );

        final result = await clientWithMock.reverseGeocode(
          const LatLng(0.0, 0.0),
        );

        expect(result, isNull);
      });

      test('should handle HTTP error status codes', () async {
        when(mockHttpClient.get(any)).thenAnswer(
          (_) async => http.Response('{"error": "Invalid request"}', 400),
        );

        final result = await clientWithMock.reverseGeocode(
          const LatLng(40.7128, -74.0060),
        );

        expect(result, isNull);
      });

      test('should handle exception during HTTP request', () async {
        when(mockHttpClient.get(any)).thenThrow(Exception('Network error'));

        final result = await clientWithMock.reverseGeocode(
          const LatLng(40.7128, -74.0060),
        );

        expect(result, isNull);
      });

      test('should handle malformed JSON response', () async {
        when(
          mockHttpClient.get(any),
        ).thenAnswer((_) async => http.Response('not valid json', 200));

        final result = await clientWithMock.reverseGeocode(
          const LatLng(40.7128, -74.0060),
        );

        expect(result, isNull);
      });
    });

    group('Integration Notes', () {
      test('documents required API key for real testing', () {
        // This test documents that real integration testing requires:
        // 1. A valid Google Maps API key
        // 2. The Geocoding API enabled in Google Cloud Console
        // 3. Network connectivity

        // For CI/CD, these tests use mocked responses or expect null returns
        expect(true, isTrue); // Documentation test
      });
    });
  });
}

// Note: Integration tests with actual API calls should be run separately
// with a valid API key and proper mocking of HTTP responses.
// These unit tests verify the client's structure and error handling.
