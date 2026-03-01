import 'dart:developer' as developer;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../client/google_routes_api_client.dart';

/// Service for interacting with Google Maps Routes API.
///
/// Routes are always computed segment-by-segment between consecutive waypoints
/// to preserve the chronological order of trip updates. Previously routed
/// segments are cached in memory so that adding a new trip update only
/// triggers a single API call for the new segment.
class DirectionsService {
  final GoogleRoutesApiClient _client;

  /// In-memory cache: segment key → list of route points for that segment.
  /// Key format: "lat1,lng1|lat2,lng2"
  static final Map<String, List<LatLng>> _segmentCache = {};

  DirectionsService(String apiKey) : _client = GoogleRoutesApiClient(apiKey);

  /// Build a stable cache key for a segment between two points.
  static String _segmentKey(LatLng from, LatLng to) {
    return '${from.latitude},${from.longitude}|${to.latitude},${to.longitude}';
  }

  /// Get walking directions between consecutive waypoints.
  ///
  /// Computes the shortest walking path between each pair of adjacent
  /// waypoints (1→2, 2→3, …, n-1→n). Cached segments are reused so
  /// only new segments trigger an API call.
  ///
  /// Throws if all routing attempts fail completely.
  Future<List<LatLng>> getDirections(List<LatLng> waypoints) async {
    if (waypoints.length < 2) {
      return waypoints;
    }

    return _getDirectionsSegmentBySegment(waypoints);
  }

  /// Computes routes segment by segment between each pair of adjacent
  /// waypoints. Checks the cache before calling the API. Successfully
  /// routed segments are stored in the cache for later reuse.
  /// If a walking route cannot be found for a segment, a straight line
  /// (the two endpoints) is used for that segment.
  Future<List<LatLng>> _getDirectionsSegmentBySegment(
    List<LatLng> waypoints,
  ) async {
    final allPoints = <LatLng>[];
    bool anySegmentRouted = false;

    for (int i = 0; i < waypoints.length - 1; i++) {
      final from = waypoints[i];
      final to = waypoints[i + 1];
      final key = _segmentKey(from, to);

      // Check cache first
      final cached = _segmentCache[key];
      if (cached != null) {
        if (allPoints.isNotEmpty && cached.isNotEmpty) {
          allPoints.addAll(cached.sublist(1));
        } else {
          allPoints.addAll(cached);
        }
        anySegmentRouted = true;
        continue;
      }

      // Cache miss — call the API for this single segment
      try {
        final result = await _client.getWalkingRoute([from, to]);
        if (result.isSuccess) {
          // Store in cache
          _segmentCache[key] = List.unmodifiable(result.points);

          // Skip the first point of subsequent segments to avoid duplicates
          if (allPoints.isNotEmpty && result.points.isNotEmpty) {
            allPoints.addAll(result.points.sublist(1));
          } else {
            allPoints.addAll(result.points);
          }
          anySegmentRouted = true;
          continue;
        }
      } catch (e) {
        developer.log(
          'Segment $i routing failed, using straight line: $e',
          name: 'DirectionsService',
        );
      }

      // Fallback: straight line for this segment
      if (allPoints.isNotEmpty) {
        allPoints.add(to);
      } else {
        allPoints.add(from);
        allPoints.add(to);
      }
    }

    if (allPoints.isEmpty) {
      throw Exception('All routing attempts failed');
    }

    if (!anySegmentRouted) {
      // No segment was successfully routed — throw so caller uses its fallback
      throw Exception('No walking routes found for any segment');
    }

    return allPoints;
  }

  /// Clears the in-memory segment cache.
  /// Useful for testing or when the user wants to force-refresh routes.
  static void clearCache() {
    _segmentCache.clear();
  }

  /// Returns the current number of cached segments (for diagnostics/testing).
  static int get cacheSize => _segmentCache.length;
}
