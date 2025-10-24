import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Widget displaying Google Map with markers and polylines
class TripMapView extends StatelessWidget {
  final LatLng initialLocation;
  final double initialZoom;
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final Function(GoogleMapController)? onMapCreated;

  const TripMapView({
    super.key,
    required this.initialLocation,
    required this.initialZoom,
    required this.markers,
    required this.polylines,
    this.onMapCreated,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: initialLocation,
          zoom: initialZoom,
        ),
        markers: markers,
        polylines: polylines,
        onMapCreated: onMapCreated,
        myLocationEnabled: false,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
      ),
    );
  }
}
