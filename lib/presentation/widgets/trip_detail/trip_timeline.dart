import 'package:flutter/material.dart';
import 'package:tracker_frontend/data/models/trip_models.dart';
import 'package:tracker_frontend/core/theme/wanderer_theme.dart';

/// Widget displaying the timeline of trip updates
class TripTimeline extends StatelessWidget {
  final List<TripLocation> updates;
  final bool isLoading;
  final VoidCallback onRefresh;
  final Function(TripLocation)? onUpdateTap;

  const TripTimeline({
    super.key,
    required this.updates,
    required this.isLoading,
    required this.onRefresh,
    this.onUpdateTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: WandererTheme.primaryOrange,
              strokeWidth: 2,
            ),
            const SizedBox(height: 16),
            Text(
              'Loading timeline...',
              style: TextStyle(
                color: WandererTheme.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    if (updates.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: WandererTheme.primaryOrange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.timeline,
                  size: 48,
                  color: WandererTheme.primaryOrange,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'No updates yet',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: WandererTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Trip updates will appear here',
                style: TextStyle(
                  fontSize: 14,
                  color: WandererTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Refresh'),
                style: TextButton.styleFrom(
                  foregroundColor: WandererTheme.primaryOrange,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      color: WandererTheme.primaryOrange,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: updates.length,
        itemBuilder: (context, index) {
          final update = updates[index];
          final isLast = index == updates.length - 1;
          final isFirst = index == 0;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline connector
              SizedBox(
                width: 24,
                child: Column(
                  children: [
                    // Connector line above (if not first)
                    if (!isFirst)
                      Container(
                        width: 2,
                        height: 8,
                        color: WandererTheme.timelineConnector,
                      ),
                    // Timeline node
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: isFirst
                            ? WandererTheme.primaryOrange
                            : WandererTheme.timelineConnector,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isFirst
                              ? WandererTheme.primaryOrange
                              : Colors.grey.shade400,
                          width: 2,
                        ),
                      ),
                    ),
                    // Connector line below (if not last)
                    if (!isLast)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Container(
                          width: 2,
                          height: 80,
                          color: WandererTheme.timelineConnector,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Update card
              Expanded(
                child: GestureDetector(
                  onTap:
                      onUpdateTap != null ? () => onUpdateTap!(update) : null,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isFirst
                          ? Colors.white.withOpacity(0.8)
                          : Colors.white.withOpacity(0.5),
                      borderRadius:
                          BorderRadius.circular(WandererTheme.glassRadiusSmall),
                      border: Border.all(
                        color: isFirst
                            ? WandererTheme.primaryOrange.withOpacity(0.3)
                            : WandererTheme.glassBorderColor,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header: timestamp and battery
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _formatTimestamp(update.timestamp),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isFirst
                                      ? WandererTheme.primaryOrange
                                      : WandererTheme.textSecondary,
                                ),
                              ),
                            ),
                            if (update.battery != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _getBatteryColor(update.battery!)
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _getBatteryIcon(update.battery!),
                                      size: 12,
                                      color: _getBatteryColor(update.battery!),
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      '${update.battery}%',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color:
                                            _getBatteryColor(update.battery!),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Location
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 14,
                              color: WandererTheme.primaryOrange,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                update.displayLocation,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: WandererTheme.textPrimary,
                                  fontWeight: update.city != null
                                      ? FontWeight.w500
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Message if present
                        if (update.message != null &&
                            update.message!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: WandererTheme.backgroundLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              update.message!,
                              style: TextStyle(
                                fontSize: 12,
                                color: WandererTheme.textSecondary,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                        // Reactions if present
                        if (update.reactionCount > 0) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.favorite,
                                size: 12,
                                color: Colors.red.shade400,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${update.reactionCount}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: WandererTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ], // closes Column children
                    ), // closes Column
                  ), // closes Container
                ), // closes GestureDetector
              ), // closes Expanded
            ], // closes Row children
          ); // closes Row
        },
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }

  IconData _getBatteryIcon(int battery) {
    if (battery >= 90) return Icons.battery_full;
    if (battery >= 70) return Icons.battery_6_bar;
    if (battery >= 50) return Icons.battery_5_bar;
    if (battery >= 30) return Icons.battery_3_bar;
    if (battery >= 20) return Icons.battery_2_bar;
    return Icons.battery_1_bar;
  }

  Color _getBatteryColor(int battery) {
    if (battery >= 50) return Colors.green;
    if (battery >= 20) return Colors.orange;
    return Colors.red;
  }
}
