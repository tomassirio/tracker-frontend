import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:wanderer_frontend/core/constants/api_endpoints.dart';
import 'package:wanderer_frontend/data/client/google_directions_api_client.dart';
import 'package:wanderer_frontend/data/client/polyline_codec.dart';
import 'package:wanderer_frontend/data/models/trip_models.dart';
import 'package:wanderer_frontend/data/services/trip_plan_service.dart';
import 'package:wanderer_frontend/presentation/helpers/ui_helpers.dart';
import 'package:wanderer_frontend/presentation/helpers/trip_plan_map_helper.dart';
import 'package:wanderer_frontend/presentation/widgets/trip_plans/trip_plan_info_card.dart';
import 'package:wanderer_frontend/core/theme/wanderer_theme.dart';

/// Screen for viewing and editing a trip plan
class TripPlanDetailScreen extends StatefulWidget {
  final TripPlan tripPlan;

  const TripPlanDetailScreen({super.key, required this.tripPlan});

  @override
  State<TripPlanDetailScreen> createState() => _TripPlanDetailScreenState();
}

class _TripPlanDetailScreenState extends State<TripPlanDetailScreen> {
  final TripPlanService _tripPlanService = TripPlanService();
  late final GoogleDirectionsApiClient _directionsClient;
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

  // Edit mode map state
  List<LatLng> _editWaypoints = [];
  LatLng? _editStartLocation;
  LatLng? _editEndLocation;
  bool _editFormExpanded = false;
  bool _showEditWaypointsList = false;

  @override
  void initState() {
    super.initState();
    _directionsClient =
        GoogleDirectionsApiClient(ApiEndpoints.googleMapsApiKey);
    _tripPlan = widget.tripPlan;
    _nameController = TextEditingController(text: _tripPlan.name);
    _selectedPlanType = _tripPlan.planType;
    _startDate = _tripPlan.startDate;
    _endDate = _tripPlan.endDate;
    _initEditLocations();
    _updateMapData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mapController?.dispose();
    _directionsClient.dispose();
    super.dispose();
  }

  /// Updates map data using backend polyline or straight-line fallback
  void _updateMapData() {
    try {
      final mapData = TripPlanMapHelper.createMapDataWithDirections(
        _tripPlan,
        onWaypointTap: _showWaypointOptions,
      );
      setState(() {
        _markers = mapData.markers;
        _polylines = mapData.polylines;
      });
    } catch (e) {
      // Fallback to straight lines if decoding fails
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

  /// Populates the editable location fields from the current trip plan
  void _initEditLocations() {
    _editWaypoints =
        _tripPlan.waypoints.map((w) => LatLng(w.lat, w.lon)).toList();
    _editStartLocation = _tripPlan.startLocation != null
        ? LatLng(_tripPlan.startLocation!.lat, _tripPlan.startLocation!.lon)
        : null;
    _editEndLocation = _tripPlan.endLocation != null
        ? LatLng(_tripPlan.endLocation!.lat, _tripPlan.endLocation!.lon)
        : null;
  }

  /// Shows info for a waypoint in view mode (no delete)
  void _showWaypointOptions(int waypointIndex) {
    final waypoint = _tripPlan.waypoints[waypointIndex];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: WandererTheme.backgroundLight,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Row(
                children: [
                  const Icon(Icons.more_horiz, color: Colors.blue, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    'Waypoint ${waypointIndex + 1}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: Icon(Icons.location_on, color: Colors.blue.shade300),
              title: Text(
                '${waypoint.lat.toStringAsFixed(4)}, ${waypoint.lon.toStringAsFixed(4)}',
              ),
              subtitle: Text(
                'Tap Edit in the toolbar to modify',
                style: TextStyle(
                  fontSize: 12,
                  color: WandererTheme.textTertiary,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
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
      // Build ordered points for polyline computation
      final points = <LatLng>[];
      final startLoc = _editStartLocation ??
          (_tripPlan.startLocation != null
              ? LatLng(
                  _tripPlan.startLocation!.lat, _tripPlan.startLocation!.lon)
              : null);
      final endLoc = _editEndLocation ??
          (_tripPlan.endLocation != null
              ? LatLng(_tripPlan.endLocation!.lat, _tripPlan.endLocation!.lon)
              : null);

      if (startLoc != null) points.add(startLoc);
      points.addAll(_editWaypoints);
      if (endLoc != null) points.add(endLoc);

      // Compute road-snapped polyline from Directions API
      String? encodedPolyline;
      if (points.length >= 2) {
        final result = await _directionsClient.getRoutePolyline(points);
        encodedPolyline = result ?? PolylineCodec.encode(points);
      }

      final request = UpdateTripPlanRequest(
        name: _nameController.text.trim(),
        startDate: _startDate,
        endDate: _endDate,
        startLocation: _editStartLocation != null
            ? PlanLocation(
                lat: _editStartLocation!.latitude,
                lon: _editStartLocation!.longitude,
              )
            : _tripPlan.startLocation,
        endLocation: _editEndLocation != null
            ? PlanLocation(
                lat: _editEndLocation!.latitude,
                lon: _editEndLocation!.longitude,
              )
            : _tripPlan.endLocation,
        waypoints: _editWaypoints
            .map((w) => PlanLocation(lat: w.latitude, lon: w.longitude))
            .toList(),
        plannedPolyline: encodedPolyline,
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
        _initEditLocations();
        _updateMapData();
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
            onPressed: () {
              _initEditLocations();
              setState(() {
                _isEditing = true;
                _editFormExpanded = false;
                _showEditWaypointsList = false;
              });
            },
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
          // Floating Info Card (centered at bottom)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: Align(
                alignment: _isInfoCollapsed
                    ? Alignment.bottomLeft
                    : Alignment.bottomCenter,
                child: TripPlanInfoCard(
                  tripPlan: _tripPlan,
                  isCollapsed: _isInfoCollapsed,
                  onToggleCollapse: () {
                    setState(() {
                      _isInfoCollapsed = !_isInfoCollapsed;
                    });
                  },
                  onEdit: () {
                    _initEditLocations();
                    setState(() {
                      _isEditing = true;
                      _editFormExpanded = false;
                      _showEditWaypointsList = false;
                    });
                  },
                  onDelete: _deleteTripPlan,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the edit screen with fullscreen map and bottom sheet form
  Widget _buildEditScreen() {
    return Scaffold(
      backgroundColor: WandererTheme.backgroundLight,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Edit Trip Plan'),
        backgroundColor: Colors.white.withOpacity(0.9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            setState(() {
              _isEditing = false;
              _nameController.text = _tripPlan.name;
              _selectedPlanType = _tripPlan.planType;
              _startDate = _tripPlan.startDate;
              _endDate = _tripPlan.endDate;
              _editWaypoints =
                  _tripPlan.waypoints.map((w) => LatLng(w.lat, w.lon)).toList();
              _editStartLocation = _tripPlan.startLocation != null
                  ? LatLng(
                      _tripPlan.startLocation!.lat,
                      _tripPlan.startLocation!.lon,
                    )
                  : null;
              _editEndLocation = _tripPlan.endLocation != null
                  ? LatLng(
                      _tripPlan.endLocation!.lat,
                      _tripPlan.endLocation!.lon,
                    )
                  : null;
              _showEditWaypointsList = false;
            });
          },
          tooltip: 'Cancel',
        ),
        actions: [
          IconButton(
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: WandererTheme.primaryOrange,
                    ),
                  )
                : const Icon(Icons.check_rounded),
            onPressed: _isLoading ? null : _saveChanges,
            tooltip: 'Save',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Full-screen map with draggable markers
          Positioned.fill(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _editStartLocation ?? const LatLng(40.7128, -74.0060),
                zoom: 10,
              ),
              markers: _buildEditMarkers(),
              onMapCreated: (controller) {
                _mapController = controller;
                if (_editStartLocation != null) {
                  Future.delayed(const Duration(milliseconds: 300), () {
                    _fitEditBounds();
                  });
                }
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: false,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 56,
                bottom: _editFormExpanded ? 420 : 200,
              ),
            ),
          ),
          // Location chips
          Positioned(
            top: MediaQuery.of(context).padding.top + 64,
            left: 16,
            right: 16,
            child: _buildEditLocationChips(),
          ),
          // Floating waypoints reorder panel
          if (_showEditWaypointsList && _editWaypoints.isNotEmpty)
            Positioned(
              top: MediaQuery.of(context).padding.top + 100,
              left: 12,
              right: 12,
              bottom: _editFormExpanded ? 430 : 210,
              child: _buildEditWaypointsPanel(),
            ),
          // Bottom form sheet
          _buildEditFormSheet(),
        ],
      ),
    );
  }

  Set<Marker> _buildEditMarkers() {
    final markers = <Marker>{};
    if (_editStartLocation != null) {
      markers.add(Marker(
        markerId: const MarkerId('start'),
        position: _editStartLocation!,
        infoWindow: const InfoWindow(title: 'Start Location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        draggable: true,
        onDragEnd: (pos) => setState(() => _editStartLocation = pos),
        onTap: () => _showEditMarkerOptions('start', 'Start Location'),
      ));
    }
    if (_editEndLocation != null) {
      markers.add(Marker(
        markerId: const MarkerId('end'),
        position: _editEndLocation!,
        infoWindow: const InfoWindow(title: 'End Location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        draggable: true,
        onDragEnd: (pos) => setState(() => _editEndLocation = pos),
        onTap: () => _showEditMarkerOptions('end', 'End Location'),
      ));
    }
    for (int i = 0; i < _editWaypoints.length; i++) {
      markers.add(Marker(
        markerId: MarkerId('waypoint_${i + 1}'),
        position: _editWaypoints[i],
        infoWindow: InfoWindow(title: 'Waypoint ${i + 1}'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        draggable: true,
        onDragEnd: (pos) {
          setState(() => _editWaypoints[i] = pos);
        },
        onTap: () => _showEditMarkerOptions(
          'waypoint_${i + 1}',
          'Waypoint ${i + 1}',
        ),
      ));
    }
    return markers;
  }

  void _showEditMarkerOptions(String markerId, String title) {
    final color = markerId == 'start'
        ? Colors.green
        : markerId == 'end'
            ? Colors.red
            : Colors.blue;
    final icon = markerId == 'start'
        ? Icons.trip_origin
        : markerId == 'end'
            ? Icons.place
            : Icons.more_horiz;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: WandererTheme.backgroundLight,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Row(
                children: [
                  Icon(icon, color: color, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            if (markerId.startsWith('waypoint_'))
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text(
                  'Remove',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  final index = int.tryParse(markerId.split('_').last);
                  if (index != null &&
                      index > 0 &&
                      index <= _editWaypoints.length) {
                    setState(() => _editWaypoints.removeAt(index - 1));
                  }
                },
              ),
            ListTile(
              leading: Icon(Icons.drag_indicator_rounded,
                  color: WandererTheme.textTertiary),
              title: const Text('Drag marker on map to move'),
              subtitle: Text(
                'Long press and drag to reposition',
                style: TextStyle(
                  fontSize: 12,
                  color: WandererTheme.textTertiary,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildEditLocationChips() {
    return Row(
      children: [
        _buildEditChip(
          label: 'Start',
          isSet: _editStartLocation != null,
          color: Colors.green,
          icon: Icons.trip_origin,
        ),
        const SizedBox(width: 6),
        _buildEditChip(
          label: 'End',
          isSet: _editEndLocation != null,
          color: Colors.red,
          icon: Icons.place,
        ),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: () {
            if (_editWaypoints.isNotEmpty) {
              setState(() => _showEditWaypointsList = !_showEditWaypointsList);
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _showEditWaypointsList
                  ? Colors.blue.withOpacity(0.25)
                  : _editWaypoints.isNotEmpty
                      ? Colors.blue.withOpacity(0.15)
                      : Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _showEditWaypointsList
                    ? Colors.blue
                    : _editWaypoints.isNotEmpty
                        ? Colors.blue.withOpacity(0.4)
                        : Colors.grey.shade300,
                width: _showEditWaypointsList ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _editWaypoints.isNotEmpty
                      ? Icons.check_circle
                      : Icons.more_horiz,
                  size: 14,
                  color: _editWaypoints.isNotEmpty
                      ? Colors.blue
                      : Colors.grey.shade500,
                ),
                const SizedBox(width: 4),
                Text(
                  _editWaypoints.isEmpty
                      ? 'Waypoints'
                      : 'Waypoints (${_editWaypoints.length})',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: _showEditWaypointsList
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: _editWaypoints.isNotEmpty
                        ? Colors.blue
                        : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditChip({
    required String label,
    required bool isSet,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isSet ? color.withOpacity(0.15) : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSet ? color.withOpacity(0.4) : Colors.grey.shade300,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSet ? Icons.check_circle : icon,
            size: 14,
            color: isSet ? color : Colors.grey.shade500,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isSet ? color : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditWaypointsPanel() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 8),
            child: Row(
              children: [
                const Icon(Icons.reorder_rounded, size: 18, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Waypoints (${_editWaypoints.length})',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: WandererTheme.textPrimary,
                  ),
                ),
                const Spacer(),
                Text(
                  'Drag to reorder',
                  style: TextStyle(
                    fontSize: 11,
                    color: WandererTheme.textTertiary,
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: Icon(Icons.close_rounded,
                      size: 20, color: WandererTheme.textTertiary),
                  onPressed: () =>
                      setState(() => _showEditWaypointsList = false),
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Flexible(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(16),
              ),
              child: ReorderableListView.builder(
                shrinkWrap: true,
                itemCount: _editWaypoints.length,
                proxyDecorator: (child, index, animation) {
                  return Material(
                    elevation: 4,
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    child: child,
                  );
                },
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) newIndex--;
                    final item = _editWaypoints.removeAt(oldIndex);
                    _editWaypoints.insert(newIndex, item);
                  });
                },
                itemBuilder: (context, index) {
                  final wp = _editWaypoints[index];
                  return Container(
                    key: ValueKey(
                      'ewp_${wp.latitude}_${wp.longitude}_$index',
                    ),
                    color: Colors.white,
                    child: ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      leading: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      title: Text(
                        'Waypoint ${index + 1}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        '${wp.latitude.toStringAsFixed(4)}, ${wp.longitude.toStringAsFixed(4)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: WandererTheme.textTertiary,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () =>
                                setState(() => _editWaypoints.removeAt(index)),
                            child: Icon(
                              Icons.remove_circle_outline,
                              size: 18,
                              color: Colors.red.shade300,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.drag_handle_rounded,
                            size: 20,
                            color: WandererTheme.textTertiary,
                          ),
                        ],
                      ),
                      onTap: () {
                        _mapController?.animateCamera(
                          CameraUpdate.newLatLng(wp),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditFormSheet() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: GestureDetector(
        onVerticalDragUpdate: (details) {
          if (details.primaryDelta! < -4) {
            setState(() => _editFormExpanded = true);
          } else if (details.primaryDelta! > 4) {
            setState(() => _editFormExpanded = false);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: _editFormExpanded ? 420 : 200,
          decoration: BoxDecoration(
            color: WandererTheme.backgroundLight,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Drag handle
              GestureDetector(
                onTap: () =>
                    setState(() => _editFormExpanded = !_editFormExpanded),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 12, bottom: 8),
                  child: Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  physics: _editFormExpanded
                      ? const BouncingScrollPhysics()
                      : const NeverScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name
                      _buildEditSectionLabel('Plan Name'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        decoration: _editInputDecoration(
                          'e.g., Weekend Hiking Adventure',
                        ),
                        textCapitalization: TextCapitalization.words,
                        onTap: () {
                          if (!_editFormExpanded) {
                            setState(() => _editFormExpanded = true);
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      // Plan Type
                      _buildEditSectionLabel('Plan Type'),
                      const SizedBox(height: 10),
                      _buildEditPlanTypeSelector(),
                      const SizedBox(height: 20),
                      // Dates
                      _buildEditSectionLabel('Dates'),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildEditDateButton(
                              label: 'Start',
                              date: _startDate,
                              onTap: _selectStartDate,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildEditDateButton(
                              label: 'End',
                              date: _endDate,
                              onTap: _selectEndDate,
                            ),
                          ),
                        ],
                      ),
                      if (_startDate != null && _endDate != null) ...[
                        const SizedBox(height: 10),
                        _buildEditDaysInfo(),
                      ],
                      const SizedBox(height: 24),
                      // Save button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveChanges,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: WandererTheme.primaryOrange,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey.shade300,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Save Changes',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),
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

  Widget _buildEditPlanTypeSelector() {
    final types = [
      {'value': 'SIMPLE', 'label': 'Simple', 'icon': Icons.wb_sunny_outlined},
      {
        'value': 'MULTI_DAY',
        'label': 'Multi-Day',
        'icon': Icons.luggage_outlined,
      },
    ];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: types.map((type) {
          final isSelected = _selectedPlanType == type['value'];
          return Expanded(
            child: GestureDetector(
              onTap: () =>
                  setState(() => _selectedPlanType = type['value'] as String),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? WandererTheme.primaryOrange.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? WandererTheme.primaryOrange
                        : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      type['icon'] as IconData,
                      size: 20,
                      color: isSelected
                          ? WandererTheme.primaryOrange
                          : WandererTheme.textTertiary,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      type['label'] as String,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? WandererTheme.primaryOrange
                            : WandererTheme.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEditDateButton({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    final hasDate = date != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasDate
                ? WandererTheme.primaryOrange.withOpacity(0.5)
                : Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 18,
              color: hasDate
                  ? WandererTheme.primaryOrange
                  : WandererTheme.textTertiary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: WandererTheme.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasDate ? _formatEditDate(date) : 'Select',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: hasDate ? FontWeight.w600 : FontWeight.w400,
                      color: hasDate
                          ? WandererTheme.textPrimary
                          : WandererTheme.textTertiary,
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

  String _formatEditDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Widget _buildEditDaysInfo() {
    final days = _endDate!.difference(_startDate!).inDays + 1;
    final isMultiDay = _selectedPlanType == 'MULTI_DAY';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isMultiDay
            ? WandererTheme.primaryOrange.withOpacity(0.06)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isMultiDay
              ? WandererTheme.primaryOrange.withOpacity(0.2)
              : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.date_range_rounded,
            size: 16,
            color: isMultiDay
                ? WandererTheme.primaryOrange
                : WandererTheme.textTertiary,
          ),
          const SizedBox(width: 8),
          Text(
            days == 1 ? '1 day' : '$days days',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isMultiDay
                  ? WandererTheme.primaryOrange
                  : WandererTheme.textSecondary,
            ),
          ),
          if (isMultiDay && days > 1) ...[
            const SizedBox(width: 6),
            Text(
              '\u00b7 Multi-day trip',
              style: TextStyle(
                fontSize: 12,
                color: WandererTheme.primaryOrange.withOpacity(0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEditSectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: WandererTheme.textPrimary,
      ),
    );
  }

  InputDecoration _editInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: WandererTheme.primaryOrange,
          width: 1.5,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
    );
  }

  void _fitEditBounds() {
    final allPoints = <LatLng>[
      if (_editStartLocation != null) _editStartLocation!,
      if (_editEndLocation != null) _editEndLocation!,
      ..._editWaypoints,
    ];
    if (allPoints.length < 2 || _mapController == null) return;

    double minLat = 90, maxLat = -90, minLng = 180, maxLng = -180;
    for (final p in allPoints) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }
    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        50,
      ),
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
