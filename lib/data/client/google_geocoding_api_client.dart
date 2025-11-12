import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Client for Google Maps Geocoding API
/// Handles reverse geocoding to convert coordinates to addresses
class GoogleGeocodingApiClient {
  final String _apiKey;
  final String _baseUrl = 'https://maps.googleapis.com/maps/api/geocode/json';

  GoogleGeocodingApiClient(this._apiKey);

  /// Reverse geocode a location to get address information
  /// Returns a PlaceInfo object with city and country, or null if not found
  Future<PlaceInfo?> reverseGeocode(LatLng location) async {
    try {
      final url = Uri.parse(
        '$_baseUrl?latlng=${location.latitude},${location.longitude}&key=$_apiKey',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'OK' &&
            data['results'] != null &&
            (data['results'] as List).isNotEmpty) {
          return _parseAddressComponents(data['results'][0]);
        }
      }

      return null;
    } catch (e) {
      // Log error but don't throw - return null for graceful degradation
      return null;
    }
  }

  /// Parse address components from geocoding result
  PlaceInfo? _parseAddressComponents(Map<String, dynamic> result) {
    String? city;
    String? country;
    String? formattedAddress = result['formatted_address'];

    final components = result['address_components'] as List?;
    if (components == null) return null;

    for (final component in components) {
      final types = component['types'] as List;

      // Extract city (locality or administrative_area_level_2)
      if (types.contains('locality')) {
        city = component['long_name'];
      } else if (city == null &&
          types.contains('administrative_area_level_2')) {
        city = component['long_name'];
      } else if (city == null &&
          types.contains('administrative_area_level_1')) {
        city = component['long_name'];
      }

      // Extract country
      if (types.contains('country')) {
        country = component['long_name'];
      }
    }

    if (city != null && country != null) {
      return PlaceInfo(
        city: city,
        country: country,
        formattedAddress: formattedAddress,
      );
    }

    return null;
  }

  /// Batch reverse geocode multiple locations
  /// Returns a map of location keys to PlaceInfo
  Future<Map<String, PlaceInfo>> batchReverseGeocode(
    List<LatLng> locations,
  ) async {
    final results = <String, PlaceInfo>{};

    // Process in parallel with a reasonable delay to avoid rate limits
    for (final location in locations) {
      final key = '${location.latitude},${location.longitude}';
      final placeInfo = await reverseGeocode(location);

      if (placeInfo != null) {
        results[key] = placeInfo;
      }

      // Small delay to avoid hitting rate limits (40 requests per second)
      await Future.delayed(const Duration(milliseconds: 30));
    }

    return results;
  }
}

/// Represents place information from geocoding
class PlaceInfo {
  final String city;
  final String country;
  final String? formattedAddress;

  PlaceInfo({required this.city, required this.country, this.formattedAddress});

  String get displayName => '$city, $country';

  @override
  String toString() => displayName;
}
