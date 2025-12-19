import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tracker_frontend/data/models/requests/create_trip_plan_backend_request.dart';
import 'package:tracker_frontend/data/services/trip_plan_service.dart';
import 'package:tracker_frontend/presentation/helpers/ui_helpers.dart';

/// Screen for creating a new trip plan with map integration
class CreateTripPlanScreen extends StatefulWidget {
  const CreateTripPlanScreen({super.key});

  @override
  State<CreateTripPlanScreen> createState() => _CreateTripPlanScreenState();
}

class _CreateTripPlanScreenState extends State<CreateTripPlanScreen> {
  final TripPlanService _tripPlanService = TripPlanService();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final List<LatLng> _waypoints = [];

  // Default to user's approximate location or a central location
  static const LatLng _defaultLocation = LatLng(40.7128, -74.0060); // New York
  LatLng _initialCameraLocation = _defaultLocation;
  LatLng? _startLocation;
  LatLng? _endLocation;
  bool _isLoadingLocation = true;

  String _planType = 'SIMPLE';
  DateTime? _startDate;
  DateTime? _endDate;
  int? _multiDayTripDays;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Location services are not enabled, use default
        setState(() => _isLoadingLocation = false);
        return;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Permission denied, use default location
          setState(() => _isLoadingLocation = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Permission denied forever, use default location
        setState(() => _isLoadingLocation = false);
        return;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Location timeout'),
      );

      final userLocation = LatLng(position.latitude, position.longitude);

      setState(() {
        _initialCameraLocation = userLocation;
        _isLoadingLocation = false;
      });

      // Move camera to user's location if map is already created
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(userLocation, 12),
      );
    } catch (e) {
      // Error getting location, use default
      setState(() => _isLoadingLocation = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _onMapTapped(LatLng location) {
    setState(() {
      if (_startLocation == null) {
        _startLocation = location;
        _addMarker(
          location,
          'start',
          'Start Location',
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        );
      } else if (_endLocation == null) {
        _endLocation = location;
        _addMarker(
          location,
          'end',
          'End Location',
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        );
      } else {
        // Add as waypoint
        final waypointNumber = _waypoints.length + 1;
        _waypoints.add(location);
        _addMarker(
          location,
          'waypoint_$waypointNumber',
          'Waypoint $waypointNumber',
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        );
      }
    });
  }

  void _addMarker(
    LatLng location,
    String id,
    String title,
    BitmapDescriptor icon,
  ) {
    _markers.add(
      Marker(
        markerId: MarkerId(id),
        position: location,
        infoWindow: InfoWindow(title: title),
        icon: icon,
      ),
    );
  }

  void _clearAllMarkers() {
    setState(() {
      _markers.clear();
      _waypoints.clear();
      _startLocation = null;
      _endLocation = null;
    });
  }

  void _removeLastWaypoint() {
    if (_waypoints.isNotEmpty) {
      setState(() {
        _waypoints.removeLast();
        _markers.removeWhere(
          (marker) =>
              marker.markerId.value == 'waypoint_${_waypoints.length + 1}',
        );
      });
    } else if (_endLocation != null) {
      setState(() {
        _endLocation = null;
        _markers.removeWhere((marker) => marker.markerId.value == 'end');
      });
    } else if (_startLocation != null) {
      setState(() {
        _startLocation = null;
        _markers.removeWhere((marker) => marker.markerId.value == 'start');
      });
    }
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  Future<void> _createTripPlan() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_startLocation == null || _endLocation == null) {
      UiHelpers.showErrorMessage(
        context,
        'Please select start and end locations on the map',
      );
      return;
    }

    if (_startDate == null || _endDate == null) {
      UiHelpers.showErrorMessage(context, 'Please select start and end dates');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Build metadata if needed
      final metadata = <String, dynamic>{};
      if (_planType == 'MULTI_DAY' && _multiDayTripDays != null) {
        metadata['multiDayTrip'] = _multiDayTripDays;
      }

      final request = CreateTripPlanBackendRequest(
        name: _nameController.text.trim(),
        planType: _planType,
        startDate: _startDate!,
        endDate: _endDate!,
        startLocation: GeoLocation(
          lat: _startLocation!.latitude,
          lon: _startLocation!.longitude,
        ),
        endLocation: GeoLocation(
          lat: _endLocation!.latitude,
          lon: _endLocation!.longitude,
        ),
        waypoints: _waypoints
            .map((loc) => GeoLocation(lat: loc.latitude, lon: loc.longitude))
            .toList(),
        metadata: metadata.isNotEmpty ? metadata : null,
      );

      await _tripPlanService.createTripPlanBackend(request);

      if (mounted) {
        UiHelpers.showSuccessMessage(
          context,
          'Trip plan created successfully!',
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        UiHelpers.showErrorMessage(context, 'Error creating trip plan: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Trip Plan'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_markers.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.undo),
              tooltip: 'Remove last marker',
              onPressed: _removeLastWaypoint,
            ),
          if (_markers.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all),
              tooltip: 'Clear all markers',
              onPressed: _clearAllMarkers,
            ),
        ],
      ),
      body: Column(
        children: [
          // Map Section
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _initialCameraLocation,
                    zoom: 12,
                  ),
                  markers: _markers,
                  onMapCreated: _onMapCreated,
                  onTap: _onMapTapped,
                  myLocationButtonEnabled: true,
                  myLocationEnabled: true,
                  zoomControlsEnabled: true,
                ),
                // Map instructions overlay
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 20,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Tap on map to add locations:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _buildLocationStatus(
                            'Start',
                            _startLocation != null,
                            Colors.green,
                          ),
                          _buildLocationStatus(
                            'End',
                            _endLocation != null,
                            Colors.red,
                          ),
                          _buildLocationStatus(
                            'Waypoints',
                            _waypoints.isNotEmpty,
                            Colors.blue,
                            count: _waypoints.length,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Loading overlay while getting location
                if (_isLoadingLocation)
                  Positioned(
                    bottom: 16,
                    left: 16,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            const SizedBox(width: 8),
                            const Text('Getting your location...'),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Form Section
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Plan Name *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.title),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a plan name';
                        }
                        if (value.trim().length < 3) {
                          return 'Plan name must be at least 3 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description (Optional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _planType,
                      decoration: const InputDecoration(
                        labelText: 'Plan Type',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'SIMPLE',
                          child: Text('Simple'),
                        ),
                        DropdownMenuItem(
                          value: 'MULTI_DAY',
                          child: Text('Multi-Day'),
                        ),
                        DropdownMenuItem(
                          value: 'ROAD_TRIP',
                          child: Text('Road Trip'),
                        ),
                        DropdownMenuItem(
                          value: 'HIKING',
                          child: Text('Hiking'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _planType = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _selectStartDate,
                            icon: const Icon(Icons.calendar_today),
                            label: Text(
                              _startDate == null
                                  ? 'Start Date'
                                  : _formatDate(_startDate!),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _selectEndDate,
                            icon: const Icon(Icons.calendar_today),
                            label: Text(
                              _endDate == null
                                  ? 'End Date'
                                  : _formatDate(_endDate!),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_planType == 'MULTI_DAY') ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Number of Days',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.event),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          _multiDayTripDays = int.tryParse(value);
                        },
                      ),
                    ],
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _createTripPlan,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              'Create Trip Plan',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationStatus(
    String label,
    bool isSet,
    Color color, {
    int? count,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            isSet ? Icons.check_circle : Icons.circle_outlined,
            size: 16,
            color: isSet ? color : Colors.grey,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isSet ? Colors.black87 : Colors.grey,
            ),
          ),
          if (count != null && count > 0) ...[
            const SizedBox(width: 4),
            Text(
              '($count)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
