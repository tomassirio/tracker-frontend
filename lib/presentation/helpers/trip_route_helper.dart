import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:wanderer_frontend/data/client/polyline_codec.dart';
import 'package:wanderer_frontend/data/models/domain/trip.dart';
import 'package:wanderer_frontend/data/models/domain/trip_location.dart';

/// Shared helper for fetching and caching encoded polylines for trip cards.
///
/// All trip card widgets (TripCard, EnhancedTripCard, ProfileTripCard)
/// share the same logic for:
///   1. Using the backend-provided encoded polyline (zero API calls).
///   2. Falling back to an in-memory cache (survives navigation).
///   3. Encoding raw sorted points as a straight-line fallback.
///
/// This avoids duplicating logic across card widgets and ensures the
/// miniature map matches the trip detail view.
class TripRouteHelper {
  /// In-memory cache of encoded polylines keyed by trip ID.
  ///
  /// Once a trip's polyline has been computed (either from the backend or
  /// by encoding raw points), the encoded result is stored here so that
  /// rebuilding the card (e.g. when scrolling back into view) is instant.
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

  /// Returns an encoded polyline for a trip's locations.
  ///
  /// Priority order:
  /// 1. Backend-provided [Trip.encodedPolyline] (zero API calls — best case).
  /// 2. In-memory [_polylineCache] (instant, survives navigation).
  /// 3. Straight-line encoding of the raw sorted points.
  ///
  /// Returns null only if the trip has fewer than 2 locations.
  static String? fetchEncodedPolyline(Trip trip) {
    // 1. Backend-provided polyline (best case: zero API calls)
    if (trip.encodedPolyline != null && trip.encodedPolyline!.isNotEmpty) {
      _polylineCache[trip.id] = trip.encodedPolyline!;
      return trip.encodedPolyline;
    }

    if (trip.locations == null || trip.locations!.length < 2) return null;

    // 2. Check trip-level polyline cache
    final cached = _polylineCache[trip.id];
    if (cached != null) return cached;

    // 3. Sort locations chronologically (matching trip detail screen)
    final sortedLocations = getSortedLocations(trip);
    final allPoints = sortedLocations
        .map((loc) => LatLng(loc.latitude, loc.longitude))
        .toList();

    // 4. Encode the raw sorted points as straight-line segments
    try {
      final encoded = PolylineCodec.encode(allPoints);
      _polylineCache[trip.id] = encoded;
      return encoded;
    } catch (_) {
      return null;
    }
  }
}
