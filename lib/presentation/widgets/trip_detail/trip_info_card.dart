import 'dart:ui';
import 'package:flutter/material.dart' hide Visibility;
import 'package:tracker_frontend/data/models/trip_models.dart';
import 'package:tracker_frontend/presentation/screens/profile_screen.dart';
import 'package:tracker_frontend/presentation/helpers/page_transitions.dart';
import 'package:tracker_frontend/core/theme/wanderer_theme.dart';
import 'package:tracker_frontend/core/constants/enums.dart';
import 'package:tracker_frontend/presentation/widgets/trip_detail/trip_status_control.dart';

/// Widget displaying trip information card with glassmorphism design
/// Supports collapsible state that shows as a floating bubble
class TripInfoCard extends StatelessWidget {
  final Trip trip;
  final bool isCollapsed;
  final VoidCallback onToggleCollapse;
  final String? currentUserId;
  final bool isChangingStatus;
  final Function(TripStatus)? onStatusChange;
  final VoidCallback? onFollowUser;
  final VoidCallback? onSendFriendRequest;
  final bool isFollowing;
  final bool hasSentFriendRequest;
  final bool isAlreadyFriends;

  const TripInfoCard({
    super.key,
    required this.trip,
    required this.isCollapsed,
    required this.onToggleCollapse,
    this.currentUserId,
    this.isChangingStatus = false,
    this.onStatusChange,
    this.onFollowUser,
    this.onSendFriendRequest,
    this.isFollowing = false,
    this.hasSentFriendRequest = false,
    this.isAlreadyFriends = false,
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
            padding: const EdgeInsets.all(12),
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
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: WandererTheme.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: WandererTheme.statusChipDecoration(
                          trip.status.toJson()),
                      child: Text(
                        trip.status.toJson().toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: WandererTheme.statusTextColor(
                              trip.status.toJson()),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Collapse button
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.remove,
                          size: 16,
                          color: WandererTheme.textSecondary,
                        ),
                        onPressed: onToggleCollapse,
                        tooltip: 'Minimize',
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // User info row
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
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
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 12,
                                backgroundColor: WandererTheme.primaryOrange,
                                child: Text(
                                  trip.username.isNotEmpty
                                      ? trip.username[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '@${trip.username}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: WandererTheme.primaryOrange,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.chevron_right,
                                size: 14,
                                color: WandererTheme.primaryOrange,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Show follow/friend buttons if viewing another user's trip
                    if (onFollowUser != null ||
                        onSendFriendRequest != null) ...[
                      const SizedBox(width: 8),
                      if (onFollowUser != null)
                        Container(
                          height: 28,
                          decoration: BoxDecoration(
                            color: isFollowing
                                ? Colors.blue.withOpacity(0.7)
                                : Colors.white.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: IconButton(
                            icon: Icon(
                              isFollowing
                                  ? Icons.person_remove
                                  : Icons.person_add,
                              size: 16,
                              color: isFollowing ? Colors.white : null,
                            ),
                            onPressed: onFollowUser,
                            tooltip: isFollowing ? 'Unfollow' : 'Follow',
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            constraints: const BoxConstraints(),
                          ),
                        ),
                      if (onSendFriendRequest != null) ...[
                        const SizedBox(width: 4),
                        Container(
                          height: 28,
                          decoration: BoxDecoration(
                            color: isAlreadyFriends
                                ? Colors.green.withOpacity(0.7)
                                : hasSentFriendRequest
                                    ? Colors.orange.withOpacity(0.7)
                                    : Colors.white.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: isAlreadyFriends
                              ? Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.people,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Friends',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : IconButton(
                                  icon: Icon(
                                    hasSentFriendRequest
                                        ? Icons.person_add_disabled
                                        : Icons.person_add_alt,
                                    size: 16,
                                    color: hasSentFriendRequest
                                        ? Colors.white
                                        : null,
                                  ),
                                  onPressed: onSendFriendRequest,
                                  tooltip: hasSentFriendRequest
                                      ? 'Cancel Friend Request'
                                      : 'Send Friend Request',
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  constraints: const BoxConstraints(),
                                ),
                        ),
                      ],
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                // Stats row
                Row(
                  children: [
                    _buildStatItem(
                      Icons.comment_outlined,
                      '${trip.commentsCount}',
                      'comments',
                    ),
                    const SizedBox(width: 16),
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
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
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
                        fontSize: 13,
                        color: WandererTheme.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
                // Trip status control (mobile only, owner only)
                if (onStatusChange != null && currentUserId != null) ...[
                  const SizedBox(height: 8),
                  TripStatusControl(
                    currentStatus: trip.status,
                    isOwner: trip.userId == currentUserId,
                    isLoading: isChangingStatus,
                    onStatusChange: onStatusChange!,
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
