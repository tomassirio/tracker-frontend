import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:tracker_frontend/data/models/trip_models.dart';

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

  /// Gets the initial location for the map
  static LatLng getInitialLocation(Trip trip) {
    if (trip.locations != null && trip.locations!.isNotEmpty) {
      return LatLng(
        trip.locations!.first.latitude,
        trip.locations!.first.longitude,
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

