import 'package:flutter/material.dart';
import 'package:tracker_frontend/presentation/strategies/trip_detail_layout_strategy.dart';

/// Mobile layout strategy for trip detail screen
/// - Only one panel can be open at a time
/// - Collapsed panels show as floating bubbles
/// - Expanded panels are constrained to leave map visible
class MobileLayoutStrategy extends TripDetailLayoutStrategy {
  static const double _collapsedWidth = 88.0;
  static const double _expandedWidthRatio = 0.85;
  static const double _maxHeightRatio = 0.5;
  @override
  double calculateLeftPanelWidth(
      BoxConstraints constraints, TripDetailLayoutData data) {
    if (data.isTripInfoCollapsed && data.isCommentsCollapsed) {
      return _collapsedWidth;
    }
    return constraints.maxWidth * _expandedWidthRatio;
  }

  @override
  bool shouldLeftPanelStretchToBottom(TripDetailLayoutData data) => false;
  @override
  bool shouldTimelinePanelStretchToBottom(TripDetailLayoutData data) => false;
  @override
  Widget buildLeftPanel(BoxConstraints constraints, TripDetailLayoutData data) {
    final tripInfoCard = createTripInfoCard(data);
    final commentsSection = createCommentsSection(data);
    if (data.isTripInfoCollapsed && data.isCommentsCollapsed) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [tripInfoCard, commentsSection],
      );
    }
    if (!data.isTripInfoCollapsed && data.isCommentsCollapsed) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: constraints.maxHeight * _maxHeightRatio,
            ),
            child: SingleChildScrollView(child: tripInfoCard),
          ),
          commentsSection,
        ],
      );
    }
    if (data.isTripInfoCollapsed && !data.isCommentsCollapsed) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          tripInfoCard,
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: constraints.maxHeight * _maxHeightRatio,
            ),
            child: commentsSection,
          ),
        ],
      );
    }
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: constraints.maxHeight * 0.6),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [tripInfoCard, commentsSection],
        ),
      ),
    );
  }

  @override
  Widget buildTimelinePanel(
      BoxConstraints constraints, TripDetailLayoutData data) {
    final timelinePanel = createTimelinePanel(data);
    if (!data.isTimelineCollapsed) {
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: constraints.maxHeight * 0.6,
          maxWidth: constraints.maxWidth * _expandedWidthRatio,
        ),
        child: timelinePanel,
      );
    }
    return timelinePanel;
  }
}
