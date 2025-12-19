import 'package:flutter/material.dart';
import 'package:tracker_frontend/data/models/trip_models.dart';

/// Card widget for displaying a trip plan
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

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.map_outlined,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      plan.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (plan.startDate != null && plan.endDate != null) ...[
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${_formatDate(plan.startDate!)} - ${_formatDate(plan.endDate!)}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              Row(
                children: [
                  Icon(Icons.category, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    plan.planType,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Created ${_formatDate(plan.createdTimestamp)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                  if (onCreateTrip != null)
                    ElevatedButton.icon(
                      onPressed: onCreateTrip,
                      icon: const Icon(Icons.add_location, size: 16),
                      label: const Text('Create Trip'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
