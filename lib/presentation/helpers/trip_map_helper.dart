import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:tracker_frontend/data/models/trip_models.dart';
import 'package:tracker_frontend/data/services/directions_service.dart';
import 'package:tracker_frontend/core/constants/api_endpoints.dart';

/// Helper class for managing Google Maps markers and polylines for trips
class TripMapHelper {
  /// Creates markers and polylines from trip locations or planned route
  static MapData createMapData(Trip trip) {
    final markers = <Marker>{};
    final polylines = <Polyline>{};

    // First try actual trip updates/locations
    if (trip.locations != null && trip.locations!.isNotEmpty) {
      final locations = trip.locations!;
      final points = <LatLng>[];

      for (int i = 0; i < locations.length; i++) {
        final location = locations[i];
        final position = LatLng(location.latitude, location.longitude);
        points.add(position);

        markers.add(
          Marker(
            markerId: MarkerId(location.id),
            position: position,
            infoWindow: InfoWindow(
              title: 'Update ${i + 1}',
              snippet: location.message ?? 'Location update',
            ),
            icon: i == locations.length - 1
                ? BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueGreen,
                  )
                : BitmapDescriptor.defaultMarker,
          ),
        );
      }

      if (points.length > 1) {
        polylines.add(
          Polyline(
            polylineId: const PolylineId('route'),
            points: points,
            color: Colors.blue,
            width: 3,
          ),
        );
      }
    }
    // Fall back to planned route from trip plan
    else if (trip.hasPlannedRoute) {
      final mapData = _createPlannedRouteMapData(trip);
      return mapData;
    }

    return MapData(markers: markers, polylines: polylines);
  }

  /// Creates markers and polylines from planned route (from trip plan)
  static MapData _createPlannedRouteMapData(Trip trip) {
    final markers = <Marker>{};
    final polylines = <Polyline>{};
    final points = <LatLng>[];

    // Add start location marker (green)
    if (trip.plannedStartLocation != null &&
        trip.plannedStartLocation!.latitude != 0 &&
        trip.plannedStartLocation!.longitude != 0) {
      final startPos = LatLng(
        trip.plannedStartLocation!.latitude,
        trip.plannedStartLocation!.longitude,
      );
      points.add(startPos);
      markers.add(
        Marker(
          markerId: const MarkerId('planned_start'),
          position: startPos,
          infoWindow: const InfoWindow(title: 'Planned Start'),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );
    }

    // Add waypoint markers (blue - distinct from orange trip updates)
    if (trip.plannedWaypoints != null) {
      for (int i = 0; i < trip.plannedWaypoints!.length; i++) {
        final waypoint = trip.plannedWaypoints![i];
        if (waypoint.latitude != 0 && waypoint.longitude != 0) {
          final waypointPos = LatLng(waypoint.latitude, waypoint.longitude);
          points.add(waypointPos);
          markers.add(
            Marker(
              markerId: MarkerId('planned_waypoint_$i'),
              position: waypointPos,
              infoWindow: InfoWindow(title: 'Planned Stop ${i + 1}'),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueBlue,
              ),
            ),
          );
        }
      }
    }

    // Add end location marker (red)
    if (trip.plannedEndLocation != null &&
        trip.plannedEndLocation!.latitude != 0 &&
        trip.plannedEndLocation!.longitude != 0) {
      final endPos = LatLng(
        trip.plannedEndLocation!.latitude,
        trip.plannedEndLocation!.longitude,
      );
      points.add(endPos);
      markers.add(
        Marker(
          markerId: const MarkerId('planned_end'),
          position: endPos,
          infoWindow: const InfoWindow(title: 'Planned End'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }

    // Create polyline connecting all planned points (purple dashed line)
    if (points.length >= 2) {
      polylines.add(
        Polyline(
          polylineId: const PolylineId('planned_route'),
          points: points,
          color: Colors.purple.withOpacity(0.7),
          width: 3,
          patterns: [PatternItem.dash(20), PatternItem.gap(10)], // Dashed line
        ),
      );
    }

    return MapData(markers: markers, polylines: polylines);
  }

  /// Creates route polyline using Google Directions API
  static Future<MapData> createMapDataWithDirections(Trip trip) async {
    final markers = <Marker>{};
    final polylines = <Polyline>{};

    // First try actual trip updates/locations
    if (trip.locations != null && trip.locations!.isNotEmpty) {
      final locations = trip.locations!;
      final waypoints = <LatLng>[];

      // Create markers
      for (int i = 0; i < locations.length; i++) {
        final location = locations[i];
        final position = LatLng(location.latitude, location.longitude);
        waypoints.add(position);

        markers.add(
          Marker(
            markerId: MarkerId(location.id),
            position: position,
            infoWindow: InfoWindow(
              title: 'Update ${i + 1}',
              snippet: location.message ?? 'Location update',
            ),
            icon: i == 0
                ? BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueRed, // Start point - red
                  )
                : i == locations.length - 1
                    ? BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueGreen, // End point - green
                      )
                    : BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueOrange, // Waypoints - orange
                      ),
          ),
        );
      }

      // Get route from Directions API (or straight lines on web)
      if (waypoints.length > 1) {
        try {
          final apiKey = ApiEndpoints.googleMapsApiKey;

          final directionsService = DirectionsService(apiKey);
          final routePoints = await directionsService.getDirections(waypoints);

          // Create polyline with the route points
          polylines.add(
            Polyline(
              polylineId: const PolylineId('route'),
              points: routePoints,
              color: Colors.blue,
              width: 5,
              geodesic: false,
              visible: true,
              startCap: Cap.roundCap,
              endCap: Cap.roundCap,
              jointType: JointType.round,
            ),
          );
        } catch (e) {
          // Fallback to straight lines if Directions API fails
          polylines.add(
            Polyline(
              polylineId: const PolylineId('route'),
              points: waypoints,
              color: Colors.red,
              width: 4,
              geodesic: false,
              visible: true,
              startCap: Cap.roundCap,
              endCap: Cap.roundCap,
            ),
          );
        }
      }

      return MapData(markers: markers, polylines: polylines);
    }
    // Fall back to planned route with directions
    else if (trip.hasPlannedRoute) {
      return _createPlannedRouteMapDataWithDirections(trip);
    }

    return MapData(markers: markers, polylines: polylines);
  }

  /// Creates planned route map data with directions API
  static Future<MapData> _createPlannedRouteMapDataWithDirections(
    Trip trip,
  ) async {
    final markers = <Marker>{};
    final polylines = <Polyline>{};
    final points = <LatLng>[];

    // Add start location marker (green)
    if (trip.plannedStartLocation != null &&
        trip.plannedStartLocation!.latitude != 0 &&
        trip.plannedStartLocation!.longitude != 0) {
      final startPos = LatLng(
        trip.plannedStartLocation!.latitude,
        trip.plannedStartLocation!.longitude,
      );
      points.add(startPos);
      markers.add(
        Marker(
          markerId: const MarkerId('planned_start'),
          position: startPos,
          infoWindow: const InfoWindow(title: 'Planned Start'),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );
    }

    // Add waypoint markers (blue - distinct from orange trip updates)
    if (trip.plannedWaypoints != null) {
      for (int i = 0; i < trip.plannedWaypoints!.length; i++) {
        final waypoint = trip.plannedWaypoints![i];
        if (waypoint.latitude != 0 && waypoint.longitude != 0) {
          final waypointPos = LatLng(waypoint.latitude, waypoint.longitude);
          points.add(waypointPos);
          markers.add(
            Marker(
              markerId: MarkerId('planned_waypoint_$i'),
              position: waypointPos,
              infoWindow: InfoWindow(title: 'Planned Stop ${i + 1}'),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueBlue,
              ),
            ),
          );
        }
      }
    }

    // Add end location marker (red)
    if (trip.plannedEndLocation != null &&
        trip.plannedEndLocation!.latitude != 0 &&
        trip.plannedEndLocation!.longitude != 0) {
      final endPos = LatLng(
        trip.plannedEndLocation!.latitude,
        trip.plannedEndLocation!.longitude,
      );
      points.add(endPos);
      markers.add(
        Marker(
          markerId: const MarkerId('planned_end'),
          position: endPos,
          infoWindow: const InfoWindow(title: 'Planned End'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }

    // Get directions for planned route (purple line)
    if (points.length >= 2) {
      try {
        final apiKey = ApiEndpoints.googleMapsApiKey;
        final directionsService = DirectionsService(apiKey);
        final routePoints = await directionsService.getDirections(points);

        polylines.add(
          Polyline(
            polylineId: const PolylineId('planned_route'),
            points: routePoints,
            color: Colors.purple,
            width: 4,
            geodesic: false,
            visible: true,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
          ),
        );
      } catch (e) {
        // Fallback to dashed straight lines
        polylines.add(
          Polyline(
            polylineId: const PolylineId('planned_route'),
            points: points,
            color: Colors.purple.withOpacity(0.7),
            width: 3,
            patterns: [PatternItem.dash(20), PatternItem.gap(10)],
          ),
        );
      }
    }

    return MapData(markers: markers, polylines: polylines);
  }

  /// Gets the initial location for the map (latest location or planned start)
  static LatLng getInitialLocation(Trip trip) {
    // First try actual trip locations
    if (trip.locations != null && trip.locations!.isNotEmpty) {
      return LatLng(
        trip.locations!.last.latitude,
        trip.locations!.last.longitude,
      );
    }
    // Then try planned start location
    if (trip.plannedStartLocation != null &&
        trip.plannedStartLocation!.latitude != 0 &&
        trip.plannedStartLocation!.longitude != 0) {
      return LatLng(
        trip.plannedStartLocation!.latitude,
        trip.plannedStartLocation!.longitude,
      );
    }
    // Then try planned end location
    if (trip.plannedEndLocation != null &&
        trip.plannedEndLocation!.latitude != 0 &&
        trip.plannedEndLocation!.longitude != 0) {
      return LatLng(
        trip.plannedEndLocation!.latitude,
        trip.plannedEndLocation!.longitude,
      );
    }
    // Then try first planned waypoint
    if (trip.plannedWaypoints != null && trip.plannedWaypoints!.isNotEmpty) {
      final wp = trip.plannedWaypoints!.first;
      if (wp.latitude != 0 && wp.longitude != 0) {
        return LatLng(wp.latitude, wp.longitude);
      }
    }
    return const LatLng(40.7128, -74.0060); // Default to NYC
  }

  /// Gets the appropriate zoom level based on whether trip has locations
  static double getInitialZoom(Trip trip) {
    if (trip.locations != null && trip.locations!.isNotEmpty) {
      return 12;
    }
    if (trip.hasPlannedRoute) {
      return 10;
    }
    return 4;
  }
}

/// Data class holding map markers and polylines
class MapData {
  final Set<Marker> markers;
  final Set<Polyline> polylines;

  MapData({required this.markers, required this.polylines});
}
