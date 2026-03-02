import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tracker_frontend/data/models/trip_models.dart';
import 'package:tracker_frontend/core/constants/api_endpoints.dart';
import 'package:tracker_frontend/data/client/google_maps_api_client.dart';
import 'package:tracker_frontend/data/client/google_routes_api_client.dart';
import 'package:tracker_frontend/data/services/directions_service.dart';

/// Card widget for displaying a trip plan with map preview.
/// Matches the modern EnhancedTripCard design.
class TripPlanCard extends StatefulWidget {
  final TripPlan plan;
  final VoidCallback onTap;
  final VoidCallback? onCreateTrip;
  final VoidCallback? onDelete;

  const TripPlanCard({
    super.key,
    required this.plan,
    required this.onTap,
    this.onCreateTrip,
    this.onDelete,
  });

  @override
  State<TripPlanCard> createState() => _TripPlanCardState();
}

class _TripPlanCardState extends State<TripPlanCard> {
  String? _encodedPolyline;
  late final GoogleMapsApiClient _mapsClient;
  late final DirectionsService _directionsService;

  @override
  void initState() {
    super.initState();
    final apiKey = ApiEndpoints.googleMapsApiKey;
    _mapsClient = GoogleMapsApiClient(apiKey);
    _directionsService = DirectionsService(apiKey);
    _loadRoute();
  }

  /// Load the encoded polyline for the miniature map.
  /// Prefers the backend-provided polyline (zero API calls), falling back
  /// to client-side road-snapped routing via DirectionsService.
  Future<void> _loadRoute() async {
    // 1. Backend-provided polyline (best case: zero API calls)
    if (widget.plan.encodedPolyline != null &&
        widget.plan.encodedPolyline!.isNotEmpty) {
      if (mounted) {
        setState(() {
          _encodedPolyline = widget.plan.encodedPolyline;
        });
      }
      return;
    }

    // 2. Fallback: client-side computation via DirectionsService
    final waypoints = <LatLng>[];

    if (_hasValidLocation(widget.plan.startLocation)) {
      waypoints.add(LatLng(
          widget.plan.startLocation!.lat, widget.plan.startLocation!.lon));
    }

    for (final wp in widget.plan.waypoints) {
      if (_hasValidLocation(wp)) {
        waypoints.add(LatLng(wp.lat, wp.lon));
      }
    }

    if (_hasValidLocation(widget.plan.endLocation)) {
      waypoints.add(
          LatLng(widget.plan.endLocation!.lat, widget.plan.endLocation!.lon));
    }

    if (waypoints.length < 2) return;

    try {
      final routePoints = await _directionsService.getDirections(waypoints);
      final encoded = GoogleRoutesApiClient.encodePolyline(routePoints);

      if (mounted) {
        setState(() {
          _encodedPolyline = encoded;
        });
      }
    } catch (e) {
      debugPrint(
          'Failed to fetch route for trip plan card, using straight lines: $e');
      try {
        final encoded = GoogleRoutesApiClient.encodePolyline(waypoints);
        if (mounted) {
          setState(() {
            _encodedPolyline = encoded;
          });
        }
      } catch (_) {}
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  bool _hasValidLocation(PlanLocation? location) {
    return location != null && location.lat != 0 && location.lon != 0;
  }

  bool get _hasMapData {
    return _hasValidLocation(widget.plan.startLocation) ||
        _hasValidLocation(widget.plan.endLocation) ||
        widget.plan.waypoints.any((wp) => _hasValidLocation(wp));
  }

  String _generateStaticMapUrl() {
    final apiKey = ApiEndpoints.googleMapsApiKey;
    if (apiKey.isEmpty) return '';

    // Collect all valid points in order: start → waypoints → end
    final allPoints = <LatLng>[];
    if (_hasValidLocation(widget.plan.startLocation)) {
      allPoints.add(LatLng(
          widget.plan.startLocation!.lat, widget.plan.startLocation!.lon));
    }
    for (final wp in widget.plan.waypoints) {
      if (_hasValidLocation(wp)) {
        allPoints.add(LatLng(wp.lat, wp.lon));
      }
    }
    if (_hasValidLocation(widget.plan.endLocation)) {
      allPoints.add(
          LatLng(widget.plan.endLocation!.lat, widget.plan.endLocation!.lon));
    }

    if (allPoints.isEmpty) return '';

    // Single point: just show a marker
    if (allPoints.length == 1) {
      return _mapsClient.generateStaticMapUrl(
        center: allPoints.first,
        markers: [
          MapMarker(position: allPoints.first, color: 'green', label: 'A'),
        ],
        zoom: 10,
      );
    }

    // Multiple points: show route with A (first) and B (last) markers
    // If we have a road-snapped polyline, use it; otherwise encode the
    // raw points so the map still renders a path through all waypoints.
    final polyline =
        _encodedPolyline ?? GoogleRoutesApiClient.encodePolyline(allPoints);

    return _mapsClient.generateRouteMapUrl(
      startPoint: allPoints.first,
      endPoint: allPoints.last,
      startLabel: 'A',
      endLabel: 'B',
      encodedPolyline: polyline,
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

  String _formatPlanType(String planType) {
    return planType
        .split('_')
        .map((word) => word[0] + word.substring(1).toLowerCase())
        .join(' ');
  }

  Widget _buildInfoContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.plan.name,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            height: 1.2,
            letterSpacing: -0.3,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        if (widget.plan.startDate != null && widget.plan.endDate != null)
          Row(
            children: [
              Icon(Icons.calendar_today, size: 12, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${_formatDate(widget.plan.startDate!)} - ${_formatDate(widget.plan.endDate!)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          )
        else
          Text(
            'No dates set',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
              fontStyle: FontStyle.italic,
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: widget.onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Map preview section
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (_hasMapData && _generateStaticMapUrl().isNotEmpty)
                    Image.network(
                      _generateStaticMapUrl(),
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.grey[200]!,
                                Colors.grey[300]!,
                              ],
                            ),
                          ),
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return _buildPlaceholderMap();
                      },
                    )
                  else
                    _buildPlaceholderMap(),

                  // Subtle gradient overlay for better badge visibility
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.transparent,
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                        ],
                        stops: const [0.0, 0.25, 0.75, 1.0],
                      ),
                    ),
                  ),

                  // Plan type badge (top left)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getPlanTypeIcon(widget.plan.planType),
                            size: 14,
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatPlanType(widget.plan.planType),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Delete button (top right)
                  if (widget.onDelete != null)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.red.shade600,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(24),
                            onTap: widget.onDelete,
                            child: const Padding(
                              padding: EdgeInsets.all(8),
                              child: Icon(
                                Icons.delete_outline,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Info section
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: Colors.grey[200]!,
                    width: 1,
                  ),
                ),
              ),
              child: _buildInfoContent(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderMap() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[200]!,
            Colors.grey[300]!,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map_outlined,
              size: 40,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 4),
            Text(
              'No route set',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
