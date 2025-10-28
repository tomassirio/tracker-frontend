import 'package:flutter/material.dart';
import 'package:tracker_frontend/data/models/trip_models.dart';
import 'package:tracker_frontend/presentation/widgets/trip_detail/trip_timeline.dart';

/// Widget displaying the collapsible timeline panel
class TimelinePanel extends StatelessWidget {
  final List<TripLocation> updates;
  final bool isLoading;
  final bool isCollapsed;
  final VoidCallback onToggleCollapse;
  final VoidCallback onRefresh;

  const TimelinePanel({
    super.key,
    required this.updates,
    required this.isLoading,
    required this.isCollapsed,
    required this.onToggleCollapse,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (isCollapsed) {
      return SizedBox(
        width: 48,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            border: Border(left: BorderSide(color: Colors.grey[300]!)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 16),
              IconButton(
                icon: const Icon(Icons.chevron_left, size: 20),
                onPressed: onToggleCollapse,
                tooltip: 'Expand timeline',
              ),
              const SizedBox(height: 16),
              Expanded(
                child: RotatedBox(
                  quarterTurns: 3,
                  child: Center(
                    child: Text(
                      'Timeline',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      width: 300, // Fixed width when expanded
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(left: BorderSide(color: Colors.grey[300]!)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.timeline, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Timeline',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, size: 20),
                    onPressed: onToggleCollapse,
                    tooltip: 'Collapse timeline',
                  ),
                ],
              ),
            ),
            Expanded(
              child: TripTimeline(
                updates: updates,
                isLoading: isLoading,
                onRefresh: onRefresh,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
