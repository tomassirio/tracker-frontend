import 'package:flutter/material.dart';
import 'package:tracker_frontend/presentation/strategies/trip_detail_layout_strategy.dart';

/// Desktop layout strategy for trip detail screen
/// - Multiple panels can be open simultaneously
/// - Panels expand to fill available space
/// - Comments section uses Expanded when open
class DesktopLayoutStrategy extends TripDetailLayoutStrategy {
  static const double _collapsedWidth = 88.0;
  static const double _timelineWidth = 352.0;
  static const double _panelGap = 32.0;
  static const double _minExpandedWidth = 300.0;
  static const double _maxExpandedWidth = 500.0;

  @override
  double calculateLeftPanelWidth(
      BoxConstraints constraints, TripDetailLayoutData data) {
    if (data.isTripInfoCollapsed && data.isCommentsCollapsed) {
      return _collapsedWidth;
    }
    return (constraints.maxWidth - _timelineWidth - _panelGap)
        .clamp(_minExpandedWidth, _maxExpandedWidth);
  }

  @override
  bool shouldLeftPanelStretchToBottom(TripDetailLayoutData data) {
    return !(data.isTripInfoCollapsed && data.isCommentsCollapsed);
  }

  @override
  bool shouldTimelinePanelStretchToBottom(TripDetailLayoutData data) {
    return !data.isTimelineCollapsed;
  }

  @override
  Widget buildLeftPanel(BoxConstraints constraints, TripDetailLayoutData data) {
    final tripInfoCard = createTripInfoCard(data);
    final commentsSection = createCommentsSection(data);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: data.isTripInfoCollapsed && data.isCommentsCollapsed
          ? MainAxisSize.min
          : MainAxisSize.max,
      children: [
        tripInfoCard,
        if (data.isCommentsCollapsed)
          commentsSection
        else
          Expanded(child: commentsSection),
      ],
    );
  }

  @override
  Widget buildTimelinePanel(
      BoxConstraints constraints, TripDetailLayoutData data) {
    return createTimelinePanel(data);
  }
}
