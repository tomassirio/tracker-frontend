import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tracker_frontend/data/models/domain/trip_location.dart';
import 'package:tracker_frontend/presentation/widgets/trip_detail/custom_info_window.dart';

/// Widget displaying the Google Maps view for a trip
class TripMapView extends StatefulWidget {
  final LatLng initialLocation;
  final double initialZoom;
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final Function(GoogleMapController) onMapCreated;

  /// Whether the current user is the owner of this trip.
  /// When false, the user's current location (blue dot) is hidden
  /// to protect the viewer's privacy.
  final bool isOwner;

  /// Whether map gestures (scroll, zoom, pan) are enabled.
  /// Set to false when overlays are open to prevent touch events
  /// from propagating to the map on mobile web.
  final bool gesturesEnabled;

  /// The currently selected location to show in the custom info window.
  final TripLocation? selectedLocation;

  /// Callback to close the custom info window.
  final VoidCallback? onInfoWindowClosed;

  const TripMapView({
    super.key,
    required this.initialLocation,
    required this.initialZoom,
    required this.markers,
    required this.polylines,
    required this.onMapCreated,
    this.isOwner = false,
    this.gesturesEnabled = true,
    this.selectedLocation,
    this.onInfoWindowClosed,
  });

  @override
  State<TripMapView> createState() => _TripMapViewState();
}

class _TripMapViewState extends State<TripMapView> {
  bool _hasError = false;
  String? _errorMessage;
  bool _isMapReady = false;

  @override
  void initState() {
    super.initState();
    // Give the map a moment to initialize
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && !_isMapReady && !_hasError) {
        // Map should have initialized by now
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        color: Colors.grey[200],
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.map_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Map Loading Error',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _errorMessage ?? 'Failed to load Google Maps',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'Coordinates: ${widget.initialLocation.latitude.toStringAsFixed(4)}, ${widget.initialLocation.longitude.toStringAsFixed(4)}',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _hasError = false;
                      _errorMessage = null;
                      _isMapReady = false;
                    });
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: widget.initialLocation,
            zoom: widget.initialZoom,
          ),
          markers: widget.markers,
          polylines: widget.polylines,
          onMapCreated: (controller) {
            try {
              setState(() {
                _isMapReady = true;
              });
              widget.onMapCreated(controller);
            } catch (e) {
              setState(() {
                _hasError = true;
                _errorMessage = 'Map initialization failed: ${e.toString()}';
              });
              debugPrint('Map creation error: $e');
            }
          },
          myLocationButtonEnabled: widget.isOwner,
          myLocationEnabled: widget.isOwner,
          mapToolbarEnabled: false,
          zoomControlsEnabled: true,
          scrollGesturesEnabled: widget.gesturesEnabled,
          zoomGesturesEnabled: widget.gesturesEnabled,
          tiltGesturesEnabled: widget.gesturesEnabled,
          rotateGesturesEnabled: widget.gesturesEnabled,
        ),
        // Loading indicator while map initializes
        if (!_isMapReady && !_hasError)
          Container(
            color: Colors.grey[200],
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Loading map...',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Location: ${widget.initialLocation.latitude.toStringAsFixed(4)}, ${widget.initialLocation.longitude.toStringAsFixed(4)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
          ),
        // Custom info window overlay
        if (widget.selectedLocation != null &&
            widget.onInfoWindowClosed != null)
          Positioned(
            top: 16,
            left: 0,
            right: 0,
            child: Center(
              child: CustomInfoWindow(
                location: widget.selectedLocation!,
                onClose: widget.onInfoWindowClosed!,
              ),
            ),
          ),
      ],
    );
  }
}
