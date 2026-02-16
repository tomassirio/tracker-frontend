import 'package:flutter/material.dart';
import 'package:tracker_frontend/data/models/trip_models.dart';
import 'package:tracker_frontend/data/models/comment_models.dart';
import 'package:tracker_frontend/core/constants/enums.dart';
import 'package:tracker_frontend/presentation/widgets/trip_detail/comments_section.dart';
import 'package:tracker_frontend/presentation/widgets/trip_detail/trip_info_card.dart';
import 'package:tracker_frontend/presentation/widgets/trip_detail/timeline_panel.dart';
import 'package:tracker_frontend/presentation/widgets/trip_detail/trip_update_panel.dart';
import 'package:tracker_frontend/presentation/strategies/mobile_layout_strategy.dart';
import 'package:tracker_frontend/presentation/strategies/desktop_layout_strategy.dart';

/// Data class containing all state and callbacks needed by layout strategies
class TripDetailLayoutData {
  final Trip trip;
  final List<Comment> comments;
  final Map<String, List<Comment>> replies;
  final Map<String, bool> expandedComments;
  final List<TripLocation> tripUpdates;
  final bool isLoadingComments;
  final bool isLoadingUpdates;
  final bool isLoggedIn;
  final bool isAddingComment;
  final bool isTimelineCollapsed;
  final bool isCommentsCollapsed;
  final bool isTripInfoCollapsed;
  final bool isTripUpdateCollapsed;
  final bool isSendingUpdate;
  final CommentSortOption sortOption;
  final TextEditingController commentController;
  final ScrollController scrollController;
  final String? replyingToCommentId;
  final String? currentUserId;
  final bool isChangingStatus;
  final bool
      showTripUpdatePanel; // Only show on Android for owner when trip is in progress

  // Callbacks
  final VoidCallback onToggleTripInfo;
  final VoidCallback onToggleComments;
  final VoidCallback onToggleTimeline;
  final VoidCallback onToggleTripUpdate;
  final VoidCallback onRefreshTimeline;
  final Function(TripLocation)? onTimelineUpdateTap;
  final Function(CommentSortOption) onSortChanged;
  final Function(String) onReact;
  final Function(String) onReply;
  final Function(String, bool) onToggleReplies;
  final VoidCallback onSendComment;
  final VoidCallback onCancelReply;
  final Function(TripStatus)? onStatusChange;
  final Future<void> Function(String? message) onSendTripUpdate;
  final VoidCallback? onFollowTripOwner;
  final VoidCallback? onSendFriendRequestToTripOwner;

  const TripDetailLayoutData({
    required this.trip,
    required this.comments,
    required this.replies,
    required this.expandedComments,
    required this.tripUpdates,
    required this.isLoadingComments,
    required this.isLoadingUpdates,
    required this.isLoggedIn,
    required this.isAddingComment,
    required this.isTimelineCollapsed,
    required this.isCommentsCollapsed,
    required this.isTripInfoCollapsed,
    required this.isTripUpdateCollapsed,
    required this.isSendingUpdate,
    required this.sortOption,
    required this.commentController,
    required this.scrollController,
    this.replyingToCommentId,
    this.currentUserId,
    this.isChangingStatus = false,
    this.showTripUpdatePanel = false,
    required this.onToggleTripInfo,
    required this.onToggleComments,
    required this.onToggleTimeline,
    required this.onToggleTripUpdate,
    required this.onRefreshTimeline,
    this.onTimelineUpdateTap,
    required this.onSortChanged,
    required this.onReact,
    required this.onReply,
    required this.onToggleReplies,
    required this.onSendComment,
    required this.onCancelReply,
    this.onStatusChange,
    required this.onSendTripUpdate,
    this.onFollowTripOwner,
    this.onSendFriendRequestToTripOwner,
  });
}

/// Abstract strategy for trip detail screen layouts
/// Implementations handle platform-specific layout logic
abstract class TripDetailLayoutStrategy {
  /// Calculate the width of the left panel (trip info + comments)
  double calculateLeftPanelWidth(
      BoxConstraints constraints, TripDetailLayoutData data);

  /// Build the left panel containing trip info and comments
  Widget buildLeftPanel(BoxConstraints constraints, TripDetailLayoutData data);

  /// Build the timeline panel (right side)
  Widget buildTimelinePanel(
      BoxConstraints constraints, TripDetailLayoutData data);

  /// Whether the left panel should stretch to bottom
  bool shouldLeftPanelStretchToBottom(TripDetailLayoutData data);

  /// Whether the timeline panel should stretch to bottom
  bool shouldTimelinePanelStretchToBottom(TripDetailLayoutData data);

  /// Helper to create TripInfoCard with proper callbacks
  @protected
  TripInfoCard createTripInfoCard(TripDetailLayoutData data) {
    return TripInfoCard(
      trip: data.trip,
      isCollapsed: data.isTripInfoCollapsed,
      onToggleCollapse: data.onToggleTripInfo,
      currentUserId: data.currentUserId,
      isChangingStatus: data.isChangingStatus,
      onStatusChange: data.onStatusChange,
      onFollowUser: data.onFollowTripOwner,
      onSendFriendRequest: data.onSendFriendRequestToTripOwner,
    );
  }

  /// Helper to create CommentsSection with proper callbacks
  @protected
  CommentsSection createCommentsSection(TripDetailLayoutData data) {
    return CommentsSection(
      comments: data.comments,
      replies: data.replies,
      expandedComments: data.expandedComments,
      tripUserId: data.trip.userId,
      isLoading: data.isLoadingComments,
      isLoggedIn: data.isLoggedIn,
      isAddingComment: data.isAddingComment,
      isCollapsed: data.isCommentsCollapsed,
      sortOption: data.sortOption,
      commentController: data.commentController,
      scrollController: data.scrollController,
      replyingToCommentId: data.replyingToCommentId,
      onToggleCollapse: data.onToggleComments,
      onSortChanged: data.onSortChanged,
      onReact: data.onReact,
      onReply: data.onReply,
      onToggleReplies: data.onToggleReplies,
      onSendComment: data.onSendComment,
      onCancelReply: data.onCancelReply,
    );
  }

  /// Helper to create TimelinePanel with proper callbacks
  @protected
  TimelinePanel createTimelinePanel(TripDetailLayoutData data) {
    return TimelinePanel(
      updates: data.tripUpdates,
      isLoading: data.isLoadingUpdates,
      isCollapsed: data.isTimelineCollapsed,
      onToggleCollapse: data.onToggleTimeline,
      onRefresh: data.onRefreshTimeline,
      onUpdateTap: data.onTimelineUpdateTap,
    );
  }

  /// Helper to create TripUpdatePanel with proper callbacks
  @protected
  TripUpdatePanel createTripUpdatePanel(TripDetailLayoutData data) {
    return TripUpdatePanel(
      isCollapsed: data.isTripUpdateCollapsed,
      isLoading: data.isSendingUpdate,
      onToggleCollapse: data.onToggleTripUpdate,
      onSendUpdate: data.onSendTripUpdate,
    );
  }
}

/// Factory to get the appropriate layout strategy based on screen size
class TripDetailLayoutStrategyFactory {
  static const double mobileBreakpoint = 600.0;

  static TripDetailLayoutStrategy getStrategy(double screenWidth) {
    if (screenWidth < mobileBreakpoint) {
      return MobileLayoutStrategy();
    }
    return DesktopLayoutStrategy();
  }

  static bool isMobile(double screenWidth) {
    return screenWidth < mobileBreakpoint;
  }
}
