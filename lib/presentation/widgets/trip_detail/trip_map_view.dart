import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Widget displaying the Google Maps view for a trip
class TripMapView extends StatelessWidget {
  final LatLng initialLocation;
  final double initialZoom;
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final Function(GoogleMapController) onMapCreated;

  const TripMapView({
    super.key,
    required this.initialLocation,
    required this.initialZoom,
    required this.markers,
    required this.polylines,
    required this.onMapCreated,
  });

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: initialLocation,
        zoom: initialZoom,
      ),
      markers: markers,
      polylines: polylines,
      onMapCreated: onMapCreated,
      myLocationButtonEnabled: true,
      myLocationEnabled: true,
      mapToolbarEnabled: false,
      zoomControlsEnabled: true,
    );
  }
}
