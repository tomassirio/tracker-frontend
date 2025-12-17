import 'package:flutter/material.dart';
import 'package:tracker_frontend/data/models/trip_models.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../data/client/google_maps_api_client.dart';
import '../../../data/client/google_routes_api_client.dart';
import '../../screens/profile_screen.dart';
import '../../helpers/page_transitions.dart';

/// YouTube-style trip card with static map preview
class YouTubeTripCard extends StatefulWidget {
  final Trip trip;
  final VoidCallback onTap;

  const YouTubeTripCard({super.key, required this.trip, required this.onTap});

  @override
  State<YouTubeTripCard> createState() => _YouTubeTripCardState();
}

class _YouTubeTripCardState extends State<YouTubeTripCard> {
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

  /// Generate static map image URL from Google Maps Static API
  String _generateStaticMapUrl() {
    if (widget.trip.locations == null || widget.trip.locations!.isEmpty) {
      // Return a default/empty map URL
      return '';
    }

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

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: widget.onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Static map preview (4:3 aspect ratio)
            AspectRatio(
              aspectRatio: 4 / 3,
              child: Stack(
                children: [
                  // Static map image - now actually loading!
                  if (widget.trip.locations != null &&
                      widget.trip.locations!.isNotEmpty)
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

                  // Status badge overlay
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        widget.trip.status.toJson().toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Trip info section
            Padding(
              padding: const EdgeInsets.all(12),
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
                      if (widget.trip.visibility.toJson() == 'PUBLIC') ...[
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
                        Icon(Icons.public, size: 14, color: Colors.grey[600]),
                      ],
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
