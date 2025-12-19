import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tracker_frontend/data/models/trip_models.dart';
import 'package:tracker_frontend/core/constants/api_endpoints.dart';
import 'package:tracker_frontend/data/client/google_maps_api_client.dart';

/// Card widget for displaying a trip plan with map preview
class TripPlanCard extends StatelessWidget {
  final TripPlan plan;
  final VoidCallback onTap;
  final VoidCallback? onCreateTrip;

  const TripPlanCard({
    super.key,
    required this.plan,
    required this.onTap,
    this.onCreateTrip,
  });

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  bool _hasValidLocation(PlanLocation? location) {
    return location != null && location.lat != 0 && location.lon != 0;
  }

  bool get _hasMapData {
    return _hasValidLocation(plan.startLocation) ||
        _hasValidLocation(plan.endLocation) ||
        plan.waypoints.any((wp) => _hasValidLocation(wp));
  }

  String _generateStaticMapUrl() {
    final apiKey = ApiEndpoints.googleMapsApiKey;
    if (apiKey.isEmpty) return '';

    final mapsClient = GoogleMapsApiClient(apiKey);
    final markers = <MapMarker>[];

    // Add start marker (green)
    if (_hasValidLocation(plan.startLocation)) {
      markers.add(MapMarker(
        position: LatLng(plan.startLocation!.lat, plan.startLocation!.lon),
        color: 'green',
        label: 'S',
      ));
    }

    // Add waypoint markers (orange/yellow)
    for (int i = 0; i < plan.waypoints.length; i++) {
      final wp = plan.waypoints[i];
      if (_hasValidLocation(wp)) {
        markers.add(MapMarker(
          position: LatLng(wp.lat, wp.lon),
          color: 'orange',
        ));
      }
    }

    // Add end marker (red)
    if (_hasValidLocation(plan.endLocation)) {
      markers.add(MapMarker(
        position: LatLng(plan.endLocation!.lat, plan.endLocation!.lon),
        color: 'red',
        label: 'E',
      ));
    }

    if (markers.isEmpty) return '';

    // If we have start and end, use route map
    if (_hasValidLocation(plan.startLocation) &&
        _hasValidLocation(plan.endLocation)) {
      return mapsClient.generateRouteMapUrl(
        startPoint: LatLng(plan.startLocation!.lat, plan.startLocation!.lon),
        endPoint: LatLng(plan.endLocation!.lat, plan.endLocation!.lon),
      );
    }

    // Otherwise, just show markers centered on the first one
    return mapsClient.generateStaticMapUrl(
      center: markers.first.position,
      markers: markers,
      zoom: 10,
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

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Map preview section
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (_hasMapData)
                    Image.network(
                      _generateStaticMapUrl(),
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return _buildPlaceholderMap(context);
                      },
                    )
                  else
                    _buildPlaceholderMap(context),

                  // Plan type badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getPlanTypeIcon(plan.planType),
                            size: 14,
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatPlanType(plan.planType),
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
                ],
              ),
            ),

            // Info section
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (plan.startDate != null && plan.endDate != null)
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 12,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${_formatDate(plan.startDate!)} - ${_formatDate(plan.endDate!)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
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
                    const Spacer(),
                    if (onCreateTrip != null)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: onCreateTrip,
                          icon: const Icon(Icons.add_location, size: 16),
                          label: const Text('Create Trip'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            textStyle: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderMap(BuildContext context) {
    return Container(
      color: Colors.grey[200],
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
