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
            // Static map preview with gradient overlay
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
                            child: Icon(
                              Icons.map,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                          ),
                        );
                      },
                    )
                  else
                    Container(
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
                        child: Icon(
                          Icons.map_outlined,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),

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

                  // Top badges overlay with shadow for visibility
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        if (widget.showAllBadges)
                          StatusBadge(
                              status: widget.trip.status, compact: false),
                        if (widget.relationship != null)
                          RelationshipBadge(
                            type: widget.relationship!,
                            compact: false,
                          ),
                      ],
                    ),
                  ),

                  // Visibility badge overlay
                  if (widget.showAllBadges)
                    Positioned(
                      bottom: 10,
                      left: 10,
                      child: VisibilityBadge(
                        visibility: widget.trip.visibility,
                        compact: false,
                      ),
                    ),

                  // Delete button overlay with better contrast
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
            // Trip info section with better spacing and hierarchy
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: Colors.grey[200]!,
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Trip title with better typography
                  Text(
                    widget.trip.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                      letterSpacing: -0.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  // Username with avatar-style icon
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        PageTransitions.slideRight(
                          ProfileScreen(userId: widget.trip.userId),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.person,
                              size: 14,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '@${widget.trip.username}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Metadata row with icons
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(widget.trip.createdAt),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.comment_outlined,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.trip.commentsCount}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
