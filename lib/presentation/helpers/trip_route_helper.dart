import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tracker_frontend/core/constants/api_endpoints.dart';
import 'package:tracker_frontend/data/client/google_routes_api_client.dart';
import 'package:tracker_frontend/data/models/domain/trip.dart';
import 'package:tracker_frontend/data/models/domain/trip_location.dart';
import 'package:tracker_frontend/data/services/directions_service.dart';

/// Shared helper for fetching and caching encoded polylines for trip cards.
///
/// All trip card widgets (TripCard, EnhancedTripCard, ProfileTripCard)
/// share the same logic for:
///   1. Sorting locations chronologically (matching TripMapHelper)
///   2. Fetching road-snapped routes via DirectionsService (which caches
///      segments internally, so subsequent calls for the same trip are free)
///   3. Encoding the result as a polyline string for Static Maps API
///
/// This avoids duplicating logic across card widgets and ensures the
/// miniature map matches the trip detail view.
class TripRouteHelper {
  /// In-memory cache of encoded polylines keyed by trip ID.
  ///
  /// Once a trip's polyline has been computed (either by a card or by the
  /// trip detail screen via [cachePolyline]), the encoded result is stored
  /// here so that rebuilding the card (e.g. when scrolling back into view)
  /// doesn't trigger any API calls at all.
  static final Map<String, String> _polylineCache = {};

  /// Returns the cached encoded polyline for [tripId], or null if not cached.
  static String? getCachedPolyline(String tripId) => _polylineCache[tripId];

  /// Stores an encoded polyline for [tripId] in the cache.
  static void cachePolyline(String tripId, String encodedPolyline) {
    _polylineCache[tripId] = encodedPolyline;
  }

  /// Clears the polyline cache. Useful for testing or forced refresh.
  static void clearCache() {
    _polylineCache.clear();
  }

  /// Returns the current cache size (for diagnostics/testing).
  static int get cacheSize => _polylineCache.length;

  /// Returns trip locations sorted chronologically (oldest first).
  ///
  /// This matches the sort order used by
  /// [TripMapHelper.createMapDataWithDirections] so that the miniature
  /// polyline follows the same path as the detail view.
  static List<TripLocation> getSortedLocations(Trip trip) {
    if (trip.locations == null || trip.locations!.isEmpty) return [];
    return List<TripLocation>.from(trip.locations!)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  /// Fetches a road-snapped encoded polyline for a trip's locations.
  ///
  /// 1. Checks the in-memory [_polylineCache] first (instant).
  /// 2. Falls back to [DirectionsService.getDirections], which itself
  ///    caches individual segments — so if the trip detail screen already
  ///    computed the route, no Google API calls are made.
  /// 3. On any failure, falls back to encoding the raw sorted points as
  ///    a straight-line polyline.
  ///
  /// Returns null only if the trip has fewer than 2 locations.
  static Future<String?> fetchEncodedPolyline(Trip trip) async {
    if (trip.locations == null || trip.locations!.length < 2) return null;

    // 1. Check trip-level polyline cache
    final cached = _polylineCache[trip.id];
    if (cached != null) return cached;

    // 2. Sort locations chronologically (matching trip detail screen)
    final sortedLocations = getSortedLocations(trip);
    final allPoints = sortedLocations
        .map((loc) => LatLng(loc.latitude, loc.longitude))
        .toList();

    // 3. Try road-snapped route via DirectionsService (uses segment cache)
    try {
      final apiKey = ApiEndpoints.googleMapsApiKey;
      final directionsService = DirectionsService(apiKey);
      final routePoints = await directionsService.getDirections(allPoints);
      final encoded = GoogleRoutesApiClient.encodePolyline(routePoints);

      // Cache for future use
      _polylineCache[trip.id] = encoded;
      return encoded;
    } catch (e) {
      debugPrint(
        'TripRouteHelper: Directions API failed for trip ${trip.id}, '
        'using straight lines: $e',
      );
    }

    // 4. Fallback: encode the raw sorted points as straight-line segments
    try {
      final encoded = GoogleRoutesApiClient.encodePolyline(allPoints);
      _polylineCache[trip.id] = encoded;
      return encoded;
    } catch (_) {
      return null;
    }
  }
}
