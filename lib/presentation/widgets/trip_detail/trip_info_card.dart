import 'dart:ui';
import 'package:flutter/material.dart' hide Visibility;
import 'package:tracker_frontend/data/models/trip_models.dart';
import 'package:tracker_frontend/presentation/screens/profile_screen.dart';
import 'package:tracker_frontend/presentation/helpers/page_transitions.dart';
import 'package:tracker_frontend/core/theme/wanderer_theme.dart';

/// Widget displaying trip information card with glassmorphism design
/// Supports collapsible state that shows as a floating bubble
class TripInfoCard extends StatelessWidget {
  final Trip trip;
  final bool isCollapsed;
  final VoidCallback onToggleCollapse;

  const TripInfoCard({
    super.key,
    required this.trip,
    required this.isCollapsed,
    required this.onToggleCollapse,
  });

  @override
  Widget build(BuildContext context) {
    if (isCollapsed) {
      return _buildCollapsedBubble();
    }
    return _buildExpandedCard(context);
  }

  /// Collapsed state - floating bubble with info icon
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
              child: Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.info_outline,
                  size: 24,
                  color: WandererTheme.primaryOrange,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Expanded state - full info card
  Widget _buildExpandedCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: WandererTheme.glassBackground,
              borderRadius: BorderRadius.circular(WandererTheme.glassRadius),
              border: Border.all(
                color: WandererTheme.glassBorderColor,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title row with status chip and collapse button
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        trip.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: WandererTheme.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: WandererTheme.statusChipDecoration(
                          trip.status.toJson()),
                      child: Text(
                        trip.status.toJson().toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: WandererTheme.statusTextColor(
                              trip.status.toJson()),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Collapse button
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
                const SizedBox(height: 12),
                // User info row
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      PageTransitions.slideRight(
                        ProfileScreen(userId: trip.userId),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: WandererTheme.primaryOrange,
                          child: Text(
                            trip.username[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '@${trip.username}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: WandererTheme.primaryOrange,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.chevron_right,
                          size: 16,
                          color: WandererTheme.primaryOrange,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Stats row
                Row(
                  children: [
                    _buildStatItem(
                      Icons.comment_outlined,
                      '${trip.commentsCount}',
                      'comments',
                    ),
                    const SizedBox(width: 20),
                    _buildStatItem(
                      _getVisibilityIcon(trip.visibility.toJson()),
                      trip.visibility.toJson(),
                      '',
                    ),
                  ],
                ),
                // Description if present
                if (trip.description != null &&
                    trip.description!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: WandererTheme.glassBorderColor,
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      trip.description!,
                      style: TextStyle(
                        fontSize: 14,
                        color: WandererTheme.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: WandererTheme.textSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          label.isEmpty ? value : '$value $label',
          style: TextStyle(
            fontSize: 13,
            color: WandererTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  IconData _getVisibilityIcon(String visibility) {
    switch (visibility.toLowerCase()) {
      case 'public':
        return Icons.public;
      case 'private':
        return Icons.lock;
      case 'protected':
        return Icons.shield;
      default:
        return Icons.visibility;
    }
  }
}
