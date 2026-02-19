import 'package:flutter/material.dart';
import 'package:tracker_frontend/data/models/trip_models.dart';
import 'package:tracker_frontend/core/theme/wanderer_theme.dart';
import 'package:tracker_frontend/core/constants/enums.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../data/client/google_maps_api_client.dart';
import '../../../data/client/google_routes_api_client.dart';
import '../../helpers/auth_navigation_helper.dart';

class TripCard extends StatefulWidget {
  final Trip trip;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const TripCard({
    super.key,
    required this.trip,
    required this.onTap,
    this.onDelete,
  });

  @override
  State<TripCard> createState() => _TripCardState();
}

class _TripCardState extends State<TripCard> {
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
      // Get route between first and last location
      final firstLocation = widget.trip.locations!.first;
      final lastLocation = widget.trip.locations!.last;

      final waypoints = [
        LatLng(firstLocation.latitude, firstLocation.longitude),
        LatLng(lastLocation.latitude, lastLocation.longitude),
      ];

      final result = await _routesClient.getWalkingRoute(waypoints);

      if (result.isSuccess && mounted) {
        // Encode the route points to use in Static Maps API
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

  /// Check if trip has valid planned route
  bool get _hasPlannedRoute {
    return widget.trip.hasPlannedRoute;
  }

  /// Generate static map image URL from Google Maps Static API
  String _generateStaticMapUrl() {
    // First try actual trip locations
    if (widget.trip.locations != null && widget.trip.locations!.isNotEmpty) {
      final firstLoc = widget.trip.locations!.first;
      final lastLoc = widget.trip.locations!.last;

      if (widget.trip.locations!.length == 1) {
        // Single location
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
        // Multiple locations - show route
        return _mapsClient.generateRouteMapUrl(
          startPoint: LatLng(firstLoc.latitude, firstLoc.longitude),
          endPoint: LatLng(lastLoc.latitude, lastLoc.longitude),
          encodedPolyline: _encodedPolyline,
        );
      }
    }

    // Fall back to planned route from trip plan
    if (_hasPlannedRoute) {
      return _generatePlannedRouteMapUrl();
    }

    // No location data
    return '';
  }

  /// Generate static map URL for planned route
  String _generatePlannedRouteMapUrl() {
    final markers = <MapMarker>[];

    // Add start marker (green with "S" label)
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

    // Add waypoint markers (blue with numbered labels to distinguish from trip updates)
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

    // Add end marker (red with "E" label)
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

    // If we have start and end, use route map
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

    // Otherwise show markers
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

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.white,
          child: InkWell(
            onTap: widget.onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Map preview section with overlays
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    children: [
                      // Map or placeholder
                      if (hasMapData)
                        Image.network(
                          _generateStaticMapUrl(),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return _buildLoadingPlaceholder();
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return _buildNoMapPlaceholder();
                          },
                        )
                      else
                        _buildNoMapPlaceholder(),

                      // Gradient overlay at bottom for better text readability
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 60,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.4),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Status badge overlay (bottom left)
                      Positioned(
                        bottom: 8,
                        left: 8,
                        child: _buildStatusBadge(),
                      ),

                      // Visibility badge overlay (bottom right)
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: _buildVisibilityBadge(),
                      ),

                      // Delete button overlay (top right)
                      if (widget.onDelete != null)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: _buildDeleteButton(),
                        ),

                      // Edit indicator for own trips (top left)
                      if (widget.onDelete != null)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: _buildEditIndicator(),
                        ),
                    ],
                  ),
                ),
                // Trip info section
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Trip title
                        Text(
                          widget.trip.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: WandererTheme.textPrimary,
                            letterSpacing: -0.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        // Username row with avatar
                        InkWell(
                          onTap: () {
                            AuthNavigationHelper.navigateToUserProfile(
                              context,
                              widget.trip.userId,
                            );
                          },
                          borderRadius: BorderRadius.circular(4),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircleAvatar(
                                  radius: 10,
                                  backgroundColor: WandererTheme.primaryOrange
                                      .withOpacity(0.15),
                                  child: Text(
                                    widget.trip.username.isNotEmpty
                                        ? widget.trip.username[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                      color: WandererTheme.primaryOrange,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    '@${widget.trip.username}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: WandererTheme.textSecondary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Spacer(),
                        // Metadata row
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 12,
                              color: WandererTheme.textTertiary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatDate(widget.trip.createdAt),
                              style: TextStyle(
                                fontSize: 11,
                                color: WandererTheme.textTertiary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 12,
                              color: WandererTheme.textTertiary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.trip.commentsCount}',
                              style: TextStyle(
                                fontSize: 11,
                                color: WandererTheme.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build a loading placeholder with shimmer effect
  Widget _buildLoadingPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[200]!,
            Colors.grey[300]!,
            Colors.grey[200]!,
          ],
        ),
      ),
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            WandererTheme.primaryOrange.withOpacity(0.5),
          ),
        ),
      ),
    );
  }

  /// Build a stylish placeholder for trips without map data
  Widget _buildNoMapPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[100]!,
            Colors.grey[200]!,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Pattern background
          Positioned.fill(
            child: CustomPaint(
              painter: _MapPatternPainter(),
            ),
          ),
          // Center icon
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.map_outlined,
                size: 32,
                color: WandererTheme.primaryOrange.withOpacity(0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build colored status badge
  Widget _buildStatusBadge() {
    final statusText = widget.trip.status.toJson();
    final statusColor = _getStatusColor(widget.trip.status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.9),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(widget.trip.status),
            size: 10,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            _formatStatus(statusText),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  /// Build visibility badge
  Widget _buildVisibilityBadge() {
    final visibility = widget.trip.visibility.toJson();
    IconData icon;
    Color color;

    switch (visibility) {
      case 'PUBLIC':
        icon = Icons.public;
        color = Colors.green;
        break;
      case 'FRIENDS':
        icon = Icons.people;
        color = Colors.blue;
        break;
      default:
        icon = Icons.lock;
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        icon,
        size: 14,
        color: color,
      ),
    );
  }

  /// Build delete button
  Widget _buildDeleteButton() {
    return Material(
      color: Colors.red.withOpacity(0.9),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: widget.onDelete,
        child: const Padding(
          padding: EdgeInsets.all(6),
          child: Icon(
            Icons.delete_outline,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
    );
  }

  /// Build edit indicator for own trips
  Widget _buildEditIndicator() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: WandererTheme.primaryOrange.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: WandererTheme.primaryOrange.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(
        Icons.edit,
        size: 14,
        color: Colors.white,
      ),
    );
  }

  /// Get status color based on trip status
  Color _getStatusColor(TripStatus status) {
    switch (status) {
      case TripStatus.created:
        return const Color(0xFF6C757D); // Gray
      case TripStatus.inProgress:
        return const Color(0xFF28A745); // Green
      case TripStatus.paused:
        return const Color(0xFFFFC107); // Yellow/Amber
      case TripStatus.finished:
        return const Color(0xFF007BFF); // Blue
    }
  }

  /// Get status icon
  IconData _getStatusIcon(TripStatus status) {
    switch (status) {
      case TripStatus.created:
        return Icons.pending_outlined;
      case TripStatus.inProgress:
        return Icons.play_arrow;
      case TripStatus.paused:
        return Icons.pause;
      case TripStatus.finished:
        return Icons.check_circle_outline;
    }
  }

  /// Format status text for display
  String _formatStatus(String status) {
    switch (status.toUpperCase()) {
      case 'CREATED':
        return 'DRAFT';
      case 'IN_PROGRESS':
        return 'LIVE';
      case 'PAUSED':
        return 'PAUSED';
      case 'FINISHED':
        return 'DONE';
      default:
        return status.toUpperCase();
    }
  }
}

/// Custom painter for map pattern background
class _MapPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[300]!.withOpacity(0.5)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw grid pattern
    const spacing = 20.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
