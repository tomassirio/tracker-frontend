import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tracker_frontend/data/models/trip_models.dart';
import 'package:tracker_frontend/data/services/trip_plan_service.dart';
import 'package:tracker_frontend/presentation/helpers/ui_helpers.dart';

/// Screen for viewing and editing a trip plan
class TripPlanDetailScreen extends StatefulWidget {
  final TripPlan tripPlan;

  const TripPlanDetailScreen({super.key, required this.tripPlan});

  @override
  State<TripPlanDetailScreen> createState() => _TripPlanDetailScreenState();
}

class _TripPlanDetailScreenState extends State<TripPlanDetailScreen> {
  final TripPlanService _tripPlanService = TripPlanService();
  late TripPlan _tripPlan;
  bool _isEditing = false;
  bool _isLoading = false;

  late TextEditingController _nameController;
  late String _selectedPlanType;
  DateTime? _startDate;
  DateTime? _endDate;

  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _tripPlan = widget.tripPlan;
    _nameController = TextEditingController(text: _tripPlan.name);
    _selectedPlanType = _tripPlan.planType;
    _startDate = _tripPlan.startDate;
    _endDate = _tripPlan.endDate;
    _buildMapElements();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _buildMapElements() {
    final markers = <Marker>{};
    final points = <LatLng>[];

    // Add start location marker
    if (_tripPlan.startLocation != null &&
        _tripPlan.startLocation!.lat != 0 &&
        _tripPlan.startLocation!.lon != 0) {
      final startLatLng = LatLng(
        _tripPlan.startLocation!.lat,
        _tripPlan.startLocation!.lon,
      );
      markers.add(
        Marker(
          markerId: const MarkerId('start'),
          position: startLatLng,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: const InfoWindow(title: 'Start'),
        ),
      );
      points.add(startLatLng);
    }

    // Add waypoint markers
    for (int i = 0; i < _tripPlan.waypoints.length; i++) {
      final waypoint = _tripPlan.waypoints[i];
      if (waypoint.lat != 0 && waypoint.lon != 0) {
        final waypointLatLng = LatLng(waypoint.lat, waypoint.lon);
        markers.add(
          Marker(
            markerId: MarkerId('waypoint_$i'),
            position: waypointLatLng,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueOrange,
            ),
            infoWindow: InfoWindow(title: 'Waypoint ${i + 1}'),
          ),
        );
        points.add(waypointLatLng);
      }
    }

    // Add end location marker
    if (_tripPlan.endLocation != null &&
        _tripPlan.endLocation!.lat != 0 &&
        _tripPlan.endLocation!.lon != 0) {
      final endLatLng = LatLng(
        _tripPlan.endLocation!.lat,
        _tripPlan.endLocation!.lon,
      );
      markers.add(
        Marker(
          markerId: const MarkerId('end'),
          position: endLatLng,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: const InfoWindow(title: 'End'),
        ),
      );
      points.add(endLatLng);
    }

    // Create polyline connecting all points
    final polylines = <Polyline>{};
    if (points.length >= 2) {
      polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          points: points,
          color: Colors.blue,
          width: 3,
        ),
      );
    }

    setState(() {
      _markers = markers;
      _polylines = polylines;
    });
  }

  LatLng _getInitialCameraPosition() {
    // Try start location first
    if (_tripPlan.startLocation != null &&
        _tripPlan.startLocation!.lat != 0 &&
        _tripPlan.startLocation!.lon != 0) {
      return LatLng(_tripPlan.startLocation!.lat, _tripPlan.startLocation!.lon);
    }
    // Then try end location
    if (_tripPlan.endLocation != null &&
        _tripPlan.endLocation!.lat != 0 &&
        _tripPlan.endLocation!.lon != 0) {
      return LatLng(_tripPlan.endLocation!.lat, _tripPlan.endLocation!.lon);
    }
    // Then try first waypoint
    if (_tripPlan.waypoints.isNotEmpty &&
        _tripPlan.waypoints.first.lat != 0 &&
        _tripPlan.waypoints.first.lon != 0) {
      return LatLng(
        _tripPlan.waypoints.first.lat,
        _tripPlan.waypoints.first.lon,
      );
    }
    // Default to a general location
    return const LatLng(37.7749, -122.4194); // San Francisco
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  String _formatPlanType(String planType) {
    return planType
        .split('_')
        .map((word) => word[0] + word.substring(1).toLowerCase())
        .join(' ');
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

  Future<void> _saveChanges() async {
    if (_nameController.text.trim().isEmpty) {
      UiHelpers.showErrorMessage(context, 'Name is required');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final request = UpdateTripPlanRequest(
        name: _nameController.text.trim(),
        plannedStartDate: _startDate,
        plannedEndDate: _endDate,
      );

      final updatedPlan = await _tripPlanService.updateTripPlan(
        _tripPlan.id,
        request,
      );

      if (mounted) {
        setState(() {
          _tripPlan = updatedPlan;
          _isEditing = false;
          _isLoading = false;
        });
        UiHelpers.showSuccessMessage(context, 'Trip plan updated successfully');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        UiHelpers.showErrorMessage(context, 'Error updating trip plan: $e');
      }
    }
  }

  Future<void> _deleteTripPlan() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Trip Plan'),
        content: Text(
          'Are you sure you want to delete "${_tripPlan.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    setState(() => _isLoading = true);

    try {
      await _tripPlanService.deleteTripPlan(_tripPlan.id);
      if (mounted) {
        UiHelpers.showSuccessMessage(context, 'Trip plan deleted');
        Navigator.pop(context, true); // Return true to indicate deletion
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        UiHelpers.showErrorMessage(context, 'Error deleting trip plan: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasMapData = _markers.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Trip Plan' : _tripPlan.name),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
              tooltip: 'Edit',
            ),
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteTripPlan,
              tooltip: 'Delete',
            ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _isEditing = false;
                  _nameController.text = _tripPlan.name;
                  _selectedPlanType = _tripPlan.planType;
                  _startDate = _tripPlan.startDate;
                  _endDate = _tripPlan.endDate;
                });
              },
              tooltip: 'Cancel',
            ),
          if (_isEditing)
            IconButton(
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check),
              onPressed: _isLoading ? null : _saveChanges,
              tooltip: 'Save',
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Map Section
            Container(
              height: 300,
              color: Colors.grey.shade200,
              child: hasMapData
                  ? GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: _getInitialCameraPosition(),
                        zoom: 10,
                      ),
                      markers: _markers,
                      polylines: _polylines,
                      onMapCreated: (controller) {
                        _mapController = controller;
                        // Fit bounds to show all markers
                        if (_markers.length >= 2) {
                          _fitBounds();
                        }
                      },
                      myLocationEnabled: false,
                      zoomControlsEnabled: true,
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.map_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No location data available',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),

            // Details Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  if (_isEditing)
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                    )
                  else
                    Text(
                      _tripPlan.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Plan Type
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Plan Type',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (_isEditing)
                            DropdownButtonFormField<String>(
                              value: _selectedPlanType,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
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
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => _selectedPlanType = value);
                                }
                              },
                            )
                          else
                            Row(
                              children: [
                                Icon(
                                  _getPlanTypeIcon(_tripPlan.planType),
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _formatPlanType(_tripPlan.planType),
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Dates
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Dates',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (_isEditing) ...[
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _selectStartDate,
                                    icon: const Icon(Icons.calendar_today),
                                    label: Text(
                                      _startDate != null
                                          ? _formatDate(_startDate!)
                                          : 'Start Date',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _selectEndDate,
                                    icon: const Icon(Icons.calendar_today),
                                    label: Text(
                                      _endDate != null
                                          ? _formatDate(_endDate!)
                                          : 'End Date',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ] else ...[
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  _tripPlan.startDate != null &&
                                          _tripPlan.endDate != null
                                      ? '${_formatDate(_tripPlan.startDate!)} - ${_formatDate(_tripPlan.endDate!)}'
                                      : 'No dates set',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Locations Summary
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Route',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildLocationRow(
                            'Start',
                            _tripPlan.startLocation,
                            Colors.green,
                          ),
                          if (_tripPlan.waypoints.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              '${_tripPlan.waypoints.length} waypoint(s)',
                              style: TextStyle(
                                color: Colors.orange.shade700,
                                fontSize: 14,
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          _buildLocationRow(
                            'End',
                            _tripPlan.endLocation,
                            Colors.red,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Created Date
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Created: ${_formatDate(_tripPlan.createdTimestamp)}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationRow(String label, PlanLocation? location, Color color) {
    final hasLocation =
        location != null && location.lat != 0 && location.lon != 0;

    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: hasLocation ? color : Colors.grey,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: Text(
            hasLocation
                ? '${location.lat.toStringAsFixed(4)}, ${location.lon.toStringAsFixed(4)}'
                : 'Not set',
            style: TextStyle(
              color: hasLocation ? Colors.black87 : Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  IconData _getPlanTypeIcon(String planType) {
    switch (planType) {
      case 'SIMPLE':
        return Icons.place;
      case 'MULTI_DAY':
        return Icons.date_range;
      case 'ROAD_TRIP':
        return Icons.directions_car;
      default:
        return Icons.map;
    }
  }

  void _fitBounds() {
    if (_markers.isEmpty || _mapController == null) return;

    double minLat = 90, maxLat = -90, minLng = 180, maxLng = -180;

    for (final marker in _markers) {
      if (marker.position.latitude < minLat) minLat = marker.position.latitude;
      if (marker.position.latitude > maxLat) maxLat = marker.position.latitude;
      if (marker.position.longitude < minLng) {
        minLng = marker.position.longitude;
      }
      if (marker.position.longitude > maxLng) {
        maxLng = marker.position.longitude;
      }
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 50),
    );
  }
}
