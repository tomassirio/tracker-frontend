import 'package:flutter/gestures.dart';
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

  /// Wraps a panel widget to prevent mouse wheel scroll and click-drag
  /// events from propagating through to the map underneath on web browsers.
  Widget _wrapWithPointerAbsorber(Widget child) {
    return Listener(
      onPointerSignal: (PointerSignalEvent event) {
        // Consume mouse wheel events so they don't reach the map
      },
      child: GestureDetector(
        // Absorb drag gestures so click-drag doesn't pan the map
        onVerticalDragUpdate: (_) {},
        onHorizontalDragUpdate: (_) {},
        behavior: HitTestBehavior.translucent,
        child: child,
      ),
    );
  }

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

    return _wrapWithPointerAbsorber(
      Column(
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
      ),
    );
  }

  @override
  Widget buildTimelinePanel(
      BoxConstraints constraints, TripDetailLayoutData data) {
    final timelinePanel = createTimelinePanel(data);
    final tripUpdatePanel =
        data.showTripUpdatePanel ? createTripUpdatePanel(data) : null;

    if (tripUpdatePanel == null) {
      return _wrapWithPointerAbsorber(timelinePanel);
    }

    return _wrapWithPointerAbsorber(
      Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize:
            data.isTimelineCollapsed ? MainAxisSize.min : MainAxisSize.max,
        children: [
          if (data.isTimelineCollapsed)
            timelinePanel
          else
            Expanded(child: timelinePanel),
          tripUpdatePanel,
        ],
      ),
    );
  }
}
