import 'package:flutter/material.dart';
import 'package:tracker_frontend/data/models/trip_models.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../data/client/google_maps_api_client.dart';
import '../../../data/client/google_routes_api_client.dart';
import '../../screens/profile_screen.dart';
import '../../helpers/page_transitions.dart';
import 'visibility_badge.dart';
import 'status_badge.dart';
import 'relationship_badge.dart';

class EnhancedTripCard extends StatefulWidget {
  final Trip trip;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final RelationshipType? relationship;
  final bool showAllBadges;

  const EnhancedTripCard({
    super.key,
    required this.trip,
    required this.onTap,
    this.onDelete,
    this.relationship,
    this.showAllBadges = true,
  });

  @override
  State<EnhancedTripCard> createState() => _EnhancedTripCardState();
}

class _EnhancedTripCardState extends State<EnhancedTripCard> {
  String? _encodedPolyline;
  late final GoogleMapsApiClient _mapsClient;
  late final GoogleRoutesApiClient _routesClient;

  @override
  void initState() {
    super.initState();
    final apiKey = ApiEndpoints.googleMapsApiKey;
    _mapsClient = GoogleMapsApiClient(apiKey);
    _routesClient = GoogleRoutesApiClient(apiKey);
    _fetchRoute();
  }

  /// Fetch the walking route between first and last location
  Future<void> _fetchRoute() async {
    if (widget.trip.locations == null || widget.trip.locations!.length < 2) {
      return;
    }

    try {
      final firstLocation = widget.trip.locations!.first;
      final lastLocation = widget.trip.locations!.last;

      final waypoints = [
        LatLng(firstLocation.latitude, firstLocation.longitude),
        LatLng(lastLocation.latitude, lastLocation.longitude),
      ];

      final result = await _routesClient.getWalkingRoute(waypoints);

      if (result.isSuccess && mounted) {
        final encoded = GoogleRoutesApiClient.encodePolyline(result.points);
        setState(() {
          _encodedPolyline = encoded;
        });
      }
    } catch (e) {
      debugPrint('Failed to fetch route for trip card: $e');
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
      }
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks == 1 ? '' : 's'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months == 1 ? '' : 's'} ago';
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }

  bool get _hasPlannedRoute => widget.trip.hasPlannedRoute;

  String _generateStaticMapUrl() {
    if (widget.trip.locations != null && widget.trip.locations!.isNotEmpty) {
      final firstLoc = widget.trip.locations!.first;
      final lastLoc = widget.trip.locations!.last;

      if (widget.trip.locations!.length == 1) {
        return _mapsClient.generateStaticMapUrl(
          center: LatLng(firstLoc.latitude, firstLoc.longitude),
          markers: [
            MapMarker(
              position: LatLng(firstLoc.latitude, firstLoc.longitude),
              color: 'green',
            ),
          ],
        );
      } else {
        return _mapsClient.generateRouteMapUrl(
          startPoint: LatLng(firstLoc.latitude, firstLoc.longitude),
          endPoint: LatLng(lastLoc.latitude, lastLoc.longitude),
          encodedPolyline: _encodedPolyline,
        );
      }
    }

    if (_hasPlannedRoute) {
      return _generatePlannedRouteMapUrl();
    }

    return '';
  }

  String _generatePlannedRouteMapUrl() {
    final markers = <MapMarker>[];

    if (widget.trip.plannedStartLocation != null &&
        widget.trip.plannedStartLocation!.latitude != 0 &&
        widget.trip.plannedStartLocation!.longitude != 0) {
      markers.add(MapMarker(
        position: LatLng(
          widget.trip.plannedStartLocation!.latitude,
          widget.trip.plannedStartLocation!.longitude,
        ),
        color: 'green',
        label: 'S',
      ));
    }

    if (widget.trip.plannedWaypoints != null) {
      for (int i = 0; i < widget.trip.plannedWaypoints!.length; i++) {
        final wp = widget.trip.plannedWaypoints![i];
        if (wp.latitude != 0 && wp.longitude != 0) {
          markers.add(MapMarker(
            position: LatLng(wp.latitude, wp.longitude),
            color: 'blue',
            label: '${i + 1}',
          ));
        }
      }
    }

    if (widget.trip.plannedEndLocation != null &&
        widget.trip.plannedEndLocation!.latitude != 0 &&
        widget.trip.plannedEndLocation!.longitude != 0) {
      markers.add(MapMarker(
        position: LatLng(
          widget.trip.plannedEndLocation!.latitude,
          widget.trip.plannedEndLocation!.longitude,
        ),
        color: 'red',
        label: 'E',
      ));
    }

    if (markers.isEmpty) return '';

    if (widget.trip.plannedStartLocation != null &&
        widget.trip.plannedEndLocation != null &&
        widget.trip.plannedStartLocation!.latitude != 0 &&
        widget.trip.plannedEndLocation!.latitude != 0) {
      return _mapsClient.generateRouteMapUrl(
        startPoint: LatLng(
          widget.trip.plannedStartLocation!.latitude,
          widget.trip.plannedStartLocation!.longitude,
        ),
        endPoint: LatLng(
          widget.trip.plannedEndLocation!.latitude,
          widget.trip.plannedEndLocation!.longitude,
        ),
      );
    }

    return _mapsClient.generateStaticMapUrl(
      center: markers.first.position,
      markers: markers,
      zoom: 10,
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasMapData =
        (widget.trip.locations != null && widget.trip.locations!.isNotEmpty) ||
            _hasPlannedRoute;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: InkWell(
        onTap: widget.onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Static map preview
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                children: [
                  if (hasMapData)
                    Image.network(
                      _generateStaticMapUrl(),
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey[300],
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
                        return Container(
                          color: Colors.grey[300],
                          child: Center(
                            child: Icon(
                              Icons.map,
                              size: 48,
                              color: Colors.grey[500],
                            ),
                          ),
                        );
                      },
                    )
                  else
                    Container(
                      color: Colors.grey[300],
                      child: Center(
                        child: Icon(
                          Icons.map_outlined,
                          size: 48,
                          color: Colors.grey[500],
                        ),
                      ),
                    ),

                  // Top badges overlay
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        if (widget.showAllBadges)
                          StatusBadge(status: widget.trip.status, compact: true),
                        if (widget.relationship != null)
                          RelationshipBadge(
                            type: widget.relationship!,
                            compact: true,
                          ),
                      ],
                    ),
                  ),

                  // Visibility badge overlay
                  if (widget.showAllBadges)
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: VisibilityBadge(
                        visibility: widget.trip.visibility,
                        compact: true,
                      ),
                    ),

                  // Delete button overlay
                  if (widget.onDelete != null)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Material(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: widget.onDelete,
                          child: const Padding(
                            padding: EdgeInsets.all(6),
                            child: Icon(
                              Icons.delete_outline,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Trip info section
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Trip title
                  Text(
                    widget.trip.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Username and date
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        PageTransitions.slideRight(
                          ProfileScreen(userId: widget.trip.userId),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.person, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '@${widget.trip.username}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Metadata row
                  Row(
                    children: [
                      Text(
                        _formatDate(widget.trip.createdAt),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 3,
                        height: 3,
                        decoration: BoxDecoration(
                          color: Colors.grey[600],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.comment, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.trip.commentsCount}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  if (widget.trip.description != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      widget.trip.description!,
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
