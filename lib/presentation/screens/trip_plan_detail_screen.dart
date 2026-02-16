import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tracker_frontend/data/models/trip_models.dart';
import 'package:tracker_frontend/data/services/trip_plan_service.dart';
import 'package:tracker_frontend/presentation/helpers/ui_helpers.dart';
import 'package:tracker_frontend/presentation/helpers/trip_plan_map_helper.dart';
import 'package:tracker_frontend/presentation/widgets/trip_plans/trip_plan_info_card.dart';
import 'package:tracker_frontend/core/theme/wanderer_theme.dart';

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

  // Collapsible panel state
  bool _isInfoCollapsed = false;

  @override
  void initState() {
    super.initState();
    _tripPlan = widget.tripPlan;
    _nameController = TextEditingController(text: _tripPlan.name);
    _selectedPlanType = _tripPlan.planType;
    _startDate = _tripPlan.startDate;
    _endDate = _tripPlan.endDate;
    _updateMapData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  /// Updates map data using Directions API for road routing
  Future<void> _updateMapData() async {
    try {
      final mapData = await TripPlanMapHelper.createMapDataWithDirections(
        _tripPlan,
        onWaypointTap: _showWaypointOptions,
      );
      setState(() {
        _markers = mapData.markers;
        _polylines = mapData.polylines;
      });
    } catch (e) {
      // Fallback to straight lines if Directions API fails
      final mapData = TripPlanMapHelper.createMapData(
        _tripPlan,
        onWaypointTap: _showWaypointOptions,
      );
      setState(() {
        _markers = mapData.markers;
        _polylines = mapData.polylines;
      });
    }
  }

  /// Shows options for a waypoint (currently delete)
  void _showWaypointOptions(int waypointIndex) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: Text('Delete Waypoint ${waypointIndex + 1}'),
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteWaypoint(waypointIndex);
              },
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Cancel'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  /// Confirms and deletes a waypoint
  Future<void> _confirmDeleteWaypoint(int waypointIndex) async {
    final waypoint = _tripPlan.waypoints[waypointIndex];
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Waypoint'),
        content: Text(
          'Are you sure you want to delete Waypoint ${waypointIndex + 1} '
          '(${waypoint.lat.toStringAsFixed(4)}, ${waypoint.lon.toStringAsFixed(4)})?',
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

    await _deleteWaypoint(waypointIndex);
  }

  /// Deletes a waypoint and updates the trip plan
  Future<void> _deleteWaypoint(int waypointIndex) async {
    setState(() => _isLoading = true);

    try {
      // Create new waypoints list without the deleted waypoint
      final updatedWaypoints = List<PlanLocation>.from(_tripPlan.waypoints)
        ..removeAt(waypointIndex);

      final request = UpdateTripPlanRequest(
        waypoints: updatedWaypoints,
      );

      final planId = await _tripPlanService.updateTripPlan(
        _tripPlan.id,
        request,
      );

      // Fetch the updated plan to get full details
      final updatedPlan = await _tripPlanService.getTripPlanById(planId);

      if (mounted) {
        setState(() {
          _tripPlan = updatedPlan;
          _isLoading = false;
        });
        await _updateMapData();
        if (mounted) {
          UiHelpers.showSuccessMessage(
            context,
            'Waypoint ${waypointIndex + 1} deleted',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        UiHelpers.showErrorMessage(context, 'Error deleting waypoint: $e');
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
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

      final planId = await _tripPlanService.updateTripPlan(
        _tripPlan.id,
        request,
      );

      // Fetch the updated plan to get full details
      final updatedPlan = await _tripPlanService.getTripPlanById(planId);

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

    // When editing, show the edit form
    if (_isEditing) {
      return _buildEditScreen();
    }

    // Normal view with fullscreen map and floating info card
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(_tripPlan.name),
        backgroundColor: WandererTheme.primaryOrange.withOpacity(0.9),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => setState(() => _isEditing = true),
            tooltip: 'Edit',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteTripPlan,
            tooltip: 'Delete',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Fullscreen Map
          Positioned.fill(
            child: hasMapData
                ? GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: TripPlanMapHelper.getInitialLocation(_tripPlan),
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
                    mapToolbarEnabled: false,
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + kToolbarHeight,
                    ),
                  )
                : Container(
                    color: Colors.grey.shade200,
                    child: Center(
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
          ),
          // Floating Info Card (bottom left)
          Positioned(
            left: 0,
            bottom: 0,
            child: SafeArea(
              child: TripPlanInfoCard(
                tripPlan: _tripPlan,
                isCollapsed: _isInfoCollapsed,
                onToggleCollapse: () {
                  setState(() {
                    _isInfoCollapsed = !_isInfoCollapsed;
                  });
                },
                onEdit: () => setState(() => _isEditing = true),
                onDelete: _deleteTripPlan,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the edit screen with traditional layout
  Widget _buildEditScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Trip Plan'),
        backgroundColor: WandererTheme.primaryOrange,
        foregroundColor: Colors.white,
        actions: [
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
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
