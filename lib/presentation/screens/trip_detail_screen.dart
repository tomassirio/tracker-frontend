import 'package:flutter/material.dart' hide Visibility;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tracker_frontend/core/constants/enums.dart';
import 'package:tracker_frontend/data/models/trip_models.dart';
import 'package:tracker_frontend/data/services/trip_service.dart';

/// Trip detail screen showing trip info and location updates on a map
class TripDetailScreen extends StatefulWidget {
  final Trip trip;

  const TripDetailScreen({super.key, required this.trip});

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  final TripService _tripService = TripService();
  GoogleMapController? _mapController;
  late Trip _trip;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  bool _isLoadingLocation = false;
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _trip = widget.trip;
    _updateMapMarkers();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _updateMapMarkers() {
    _markers.clear();
    _polylines.clear();

    if (_trip.locations != null && _trip.locations!.isNotEmpty) {
      final locations = _trip.locations!;
      final points = <LatLng>[];

      for (int i = 0; i < locations.length; i++) {
        final location = locations[i];
        final position = LatLng(location.latitude, location.longitude);
        points.add(position);

        _markers.add(
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
        _polylines.add(
          Polyline(
            polylineId: const PolylineId('route'),
            points: points,
            color: Colors.blue,
            width: 3,
          ),
        );
      }
    }

    setState(() {});
  }

  Future<void> _addLocationUpdate() async {
    // Request location permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permissions are denied'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permissions are permanently denied'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoadingLocation = true;
    });

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final request = TripUpdateRequest(
        latitude: position.latitude,
        longitude: position.longitude,
        message: _messageController.text.trim().isEmpty
            ? null
            : _messageController.text.trim(),
      );

      final newLocation = await _tripService.sendTripUpdate(_trip.id, request);

      setState(() {
        _trip = Trip(
          id: _trip.id,
          userId: _trip.userId,
          title: _trip.title,
          description: _trip.description,
          visibility: _trip.visibility,
          status: _trip.status,
          startDate: _trip.startDate,
          endDate: _trip.endDate,
          locations: [...?_trip.locations, newLocation],
          commentsCount: _trip.commentsCount,
          reactionsCount: _trip.reactionsCount,
          createdAt: _trip.createdAt,
          updatedAt: DateTime.now(),
        );
        _messageController.clear();
      });

      _updateMapMarkers();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location update added!'),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Move camera to new location
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(newLocation.latitude, newLocation.longitude),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding location: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _changeTripStatus(TripStatus newStatus) async {
    try {
      final request = ChangeStatusRequest(status: newStatus);
      final updatedTrip = await _tripService.changeStatus(_trip.id, request);

      setState(() {
        _trip = updatedTrip;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Trip status changed to ${newStatus.toJson()}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error changing status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasLocations = _trip.locations != null && _trip.locations!.isNotEmpty;
    final initialLocation = hasLocations
        ? LatLng(
            _trip.locations!.first.latitude,
            _trip.locations!.first.longitude,
          )
        : const LatLng(40.7128, -74.0060); // Default to NYC

    return Scaffold(
      appBar: AppBar(
        title: Text(_trip.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          PopupMenuButton<TripStatus>(
            icon: const Icon(Icons.more_vert),
            onSelected: _changeTripStatus,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: TripStatus.in_progress,
                child: Row(
                  children: [
                    Icon(Icons.play_arrow, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Start Trip'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: TripStatus.paused,
                child: Row(
                  children: [
                    Icon(Icons.pause, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Pause Trip'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: TripStatus.finished,
                child: Row(
                  children: [
                    Icon(Icons.check, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('Finish Trip'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Trip info card
          Card(
            margin: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_trip.description != null) ...[
                    Text(
                      _trip.description!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                  ],
                  Row(
                    children: [
                      Chip(
                        label: Text(_trip.status.toJson()),
                        avatar: Icon(
                          _getStatusIcon(_trip.status),
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Chip(
                        label: Text(_trip.visibility.toJson()),
                        avatar: Icon(
                          _getVisibilityIcon(_trip.visibility),
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                  if (hasLocations) ...[
                    const SizedBox(height: 8),
                    Text(
                      '${_trip.locations!.length} location update(s)',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
          ),
          // Map
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: initialLocation,
                zoom: hasLocations ? 12 : 4,
              ),
              markers: _markers,
              polylines: _polylines,
              onMapCreated: (controller) {
                _mapController = controller;
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
          ),
          // Add location update section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    hintText: 'Add a message (optional)...',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.message),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoadingLocation ? null : _addLocationUpdate,
                    icon: _isLoadingLocation
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.add_location),
                    label: Text(
                      _isLoadingLocation
                          ? 'Getting location...'
                          : 'Add Current Location',
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(TripStatus status) {
    switch (status) {
      case TripStatus.in_progress:
        return Icons.play_arrow;
      case TripStatus.created:
        return Icons.schedule;
      case TripStatus.paused:
        return Icons.pause;
      case TripStatus.finished:
        return Icons.check;
    }
  }

  IconData _getVisibilityIcon(Visibility visibility) {
    switch (visibility) {
      case Visibility.private:
        return Icons.lock;
      case Visibility.protected:
        return Icons.group;
      case Visibility.public:
        return Icons.public;
    }
  }
}
