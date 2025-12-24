import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:tracker_frontend/data/models/trip_models.dart';
import 'package:tracker_frontend/core/theme/wanderer_theme.dart';
import 'package:tracker_frontend/presentation/widgets/trip_detail/trip_timeline.dart';

/// Widget displaying the collapsible timeline panel with glassmorphism design
/// This panel floats as a detached card for the "anti-gravity" effect
/// Collapses to a floating bubble
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
      return _buildCollapsedBubble();
    }
    return _buildExpandedPanel();
  }

  /// Collapsed state - floating bubble with timeline icon and count badge
  Widget _buildCollapsedBubble() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: WandererTheme.floatingShadow,
      ),
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: WandererTheme.glassBlurSigma,
            sigmaY: WandererTheme.glassBlurSigma,
          ),
          child: Material(
            color: WandererTheme.glassBackground,
            shape: CircleBorder(
              side: BorderSide(
                color: WandererTheme.glassBorderColor,
                width: 1,
              ),
            ),
            child: InkWell(
              onTap: onToggleCollapse,
              customBorder: const CircleBorder(),
              child: Stack(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.timeline,
                      size: 24,
                      color: WandererTheme.primaryOrange,
                    ),
                  ),
                  // Badge with count
                  if (updates.isNotEmpty)
                    Positioned(
                      right: 4,
                      top: 4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: WandererTheme.primaryOrange,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Center(
                          child: Text(
                            updates.length > 99 ? '99+' : '${updates.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Expanded state - floating detached card
  Widget _buildExpandedPanel() {
    return Container(
      margin: const EdgeInsets.all(16),
      width: 320,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(WandererTheme.glassRadius),
        boxShadow: WandererTheme.floatingShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(WandererTheme.glassRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: WandererTheme.glassBlurSigma,
            sigmaY: WandererTheme.glassBlurSigma,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: WandererTheme.glassBackground,
              borderRadius: BorderRadius.circular(WandererTheme.glassRadius),
              border: Border.all(
                color: WandererTheme.glassBorderColor,
                width: 1,
              ),
            ),
            child: Column(
              children: [
                // Header with glass styling
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.4),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(WandererTheme.glassRadius),
                      topRight: Radius.circular(WandererTheme.glassRadius),
                    ),
                    border: Border(
                      bottom: BorderSide(
                        color: WandererTheme.glassBorderColor,
                        width: 0.5,
                      ),
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
                            color: WandererTheme.textPrimary,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.remove,
                            size: 18,
                            color: WandererTheme.textSecondary,
                          ),
                          onPressed: onToggleCollapse,
                          tooltip: 'Minimize',
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          padding: EdgeInsets.zero,
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
          ),
        ),
      ),
    );
  }
}
