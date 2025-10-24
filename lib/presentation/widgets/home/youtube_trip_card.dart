import 'package:flutter/material.dart';
import 'package:tracker_frontend/data/models/trip_models.dart';
import 'package:tracker_frontend/presentation/helpers/trip_map_helper.dart';
import 'package:intl/intl.dart';

/// YouTube-style trip card with static map preview
class YouTubeTripCard extends StatelessWidget {
  final Trip trip;
  final VoidCallback onTap;

  const YouTubeTripCard({
    super.key,
    required this.trip,
    required this.onTap,
  });

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
    final initialLocation = TripMapHelper.getInitialLocation(trip);
    final zoom = TripMapHelper.getInitialZoom(trip);
    
    // Base URL for Google Maps Static API
    final baseUrl = 'https://maps.googleapis.com/maps/api/staticmap';
    
    // Center on the initial location
    final center = '${initialLocation.latitude},${initialLocation.longitude}';
    
    // Build markers parameter for trip locations
    final markers = StringBuffer();
    if (trip.locations != null && trip.locations!.isNotEmpty) {
      markers.write('&markers=');
      for (var i = 0; i < trip.locations!.length; i++) {
        final loc = trip.locations![i];
        if (i > 0) markers.write('|');
        markers.write('${loc.latitude},${loc.longitude}');
      }
    }
    
    // Build path parameter for polyline
    final path = StringBuffer();
    if (trip.locations != null && trip.locations!.length > 1) {
      path.write('&path=color:0x0000ff|weight:2');
      for (final loc in trip.locations!) {
        path.write('|${loc.latitude},${loc.longitude}');
      }
    }
    
    // Size for the static map (adjust based on card size)
    const size = '400x225'; // 16:9 ratio
    
    return '$baseUrl?center=$center&zoom=${zoom.toInt()}&size=$size${markers.toString()}${path.toString()}&key=\${GOOGLE_MAPS_API_KEY}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Static map preview (4:3 aspect ratio - smaller than before)
            AspectRatio(
              aspectRatio: 4 / 3,
              child: Stack(
                children: [
                  // Static map image
                  Container(
                    color: Colors.grey[300],
                    child: Center(
                      child: Icon(
                        Icons.map,
                        size: 48,
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
                  // Note: Static map images would require API key injection
                  // For now showing placeholder. In production, use:
                  // Image.network(_generateStaticMapUrl(), fit: BoxFit.cover)
                  
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
                        trip.status.toJson().toUpperCase(),
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
                    trip.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Username and date
                  Row(
                    children: [
                      Icon(
                        Icons.person,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        trip.username,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Metadata row
                  Row(
                    children: [
                      Text(
                        _formatDate(trip.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
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
                      Icon(
                        Icons.comment,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${trip.commentsCount}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      if (trip.visibility.toJson() == 'PUBLIC') ...[
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
                        Icon(
                          Icons.public,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                      ],
                    ],
                  ),
                  if (trip.description != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      trip.description!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
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
