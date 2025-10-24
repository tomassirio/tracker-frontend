import 'package:flutter/material.dart' hide Visibility;
import 'package:tracker_frontend/data/models/trip_models.dart';
import 'package:tracker_frontend/presentation/helpers/ui_helpers.dart';

/// Card widget displaying trip information
class TripInfoCard extends StatelessWidget {
  final Trip trip;

  const TripInfoCard({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    final hasLocations = trip.locations != null && trip.locations!.isNotEmpty;

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (trip.description != null) ...[
              Text(
                trip.description!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                Chip(
                  label: Text(trip.status.toJson()),
                  avatar: Icon(UiHelpers.getStatusIcon(trip.status), size: 16),
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(trip.visibility.toJson()),
                  avatar: Icon(
                    UiHelpers.getVisibilityIcon(trip.visibility),
                    size: 16,
                  ),
                ),
              ],
            ),
            if (hasLocations) ...[
              const SizedBox(height: 8),
              Text(
                '${trip.locations!.length} location update(s)',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
