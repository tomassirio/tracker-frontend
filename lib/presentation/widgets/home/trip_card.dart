import 'package:flutter/material.dart';
import 'package:tracker_frontend/data/models/trip_models.dart';
import 'package:tracker_frontend/presentation/helpers/ui_helpers.dart';

/// Card widget displaying a trip in the list
class TripCard extends StatelessWidget {
  final Trip trip;
  final VoidCallback onTap;

  const TripCard({super.key, required this.trip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(trip.status),
          child: Icon(
            UiHelpers.getStatusIcon(trip.status),
            color: Colors.white,
          ),
        ),
        title: Text(
          trip.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (trip.description != null) ...[
              const SizedBox(height: 4),
              Text(
                trip.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                Chip(
                  label: Text(
                    trip.status.toJson(),
                    style: const TextStyle(fontSize: 11),
                  ),
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(
                    trip.visibility.toJson(),
                    style: const TextStyle(fontSize: 11),
                  ),
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Color _getStatusColor(status) {
    switch (status.toString()) {
      case 'TripStatus.in_progress':
        return Colors.green;
      case 'TripStatus.created':
        return Colors.blue;
      case 'TripStatus.paused':
        return Colors.orange;
      case 'TripStatus.finished':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}
