import 'package:flutter/material.dart';
import 'package:tracker_frontend/data/models/trip_models.dart';
import 'package:tracker_frontend/core/theme/wanderer_theme.dart';
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
      return Container(
        width: 48,
        decoration: BoxDecoration(
          color: WandererTheme.backgroundCard,
          border: Border(
            left: BorderSide(color: Colors.grey.shade200),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(-2, 0),
            ),
          ],
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: WandererTheme.primaryOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.chevron_left,
                  size: 20,
                  color: WandererTheme.primaryOrange,
                ),
                onPressed: onToggleCollapse,
                tooltip: 'Expand timeline',
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: RotatedBox(
                quarterTurns: 3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.timeline,
                      size: 16,
                      color: WandererTheme.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Timeline',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: WandererTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: WandererTheme.backgroundCard,
        border: Border(
          left: BorderSide(color: Colors.grey.shade200),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(-2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: WandererTheme.backgroundCard,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: WandererTheme.primaryOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.timeline,
                    size: 18,
                    color: WandererTheme.primaryOrange,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Timeline',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: WandererTheme.textSecondary,
                  ),
                  onPressed: onToggleCollapse,
                  tooltip: 'Collapse timeline',
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey.shade100,
                  ),
                ),
              ],
            ),
          ),
          // Timeline content
          Expanded(
            child: TripTimeline(
              updates: updates,
              isLoading: isLoading,
              onRefresh: onRefresh,
            ),
          ),
        ],
      ),
    );
  }
}
