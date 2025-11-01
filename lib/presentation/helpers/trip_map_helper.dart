import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:tracker_frontend/data/models/trip_models.dart';
import 'package:tracker_frontend/data/services/directions_service.dart';
import 'package:tracker_frontend/core/constants/api_endpoints.dart';

/// Helper class for managing Google Maps markers and polylines for trips
class TripMapHelper {
  /// Creates markers and polylines from trip locations
  static MapData createMapData(Trip trip) {
    final markers = <Marker>{};
    final polylines = <Polyline>{};

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

    return MapData(markers: markers, polylines: polylines);
  }

  /// Creates route polyline using Google Directions API
  static Future<MapData> createMapDataWithDirections(Trip trip) async {

    final markers = <Marker>{};
    final polylines = <Polyline>{};

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
    }

    return MapData(markers: markers, polylines: polylines);
  }

  /// Gets the initial location for the map (latest location)
  static LatLng getInitialLocation(Trip trip) {
    if (trip.locations != null && trip.locations!.isNotEmpty) {
      return LatLng(
        trip.locations!.last.latitude,
        trip.locations!.last.longitude,
      );
    }
    return const LatLng(40.7128, -74.0060); // Default to NYC
  }

  /// Gets the appropriate zoom level based on whether trip has locations
  static double getInitialZoom(Trip trip) {
    return (trip.locations != null && trip.locations!.isNotEmpty) ? 12 : 4;
  }
}

/// Data class holding map markers and polylines
class MapData {
  final Set<Marker> markers;
  final Set<Polyline> polylines;

  MapData({required this.markers, required this.polylines});
}
