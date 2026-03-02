import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:tracker_frontend/presentation/strategies/trip_detail_layout_strategy.dart';

/// Blocks pointer scroll (mouse wheel) events from propagating through
/// to the Google Map underneath on desktop web. Also ensures click-drag
/// events that land on the panel are consumed by the panel's own scrollables
/// rather than leaking to the map.
class _MapEventBlocker extends StatelessWidget {
  final Widget child;

  const _MapEventBlocker({required this.child});

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: (PointerSignalEvent event) {
        if (event is PointerScrollEvent) {
          // Claim the scroll event via the resolver so the map never receives it.
          GestureBinding.instance.pointerSignalResolver.register(
            event,
            (PointerSignalEvent e) {
              // No-op: the panel's internal scrollable will handle the actual
              // scrolling through its own Listener registered earlier in the
              // hit-test order. We just need to ensure *something* claims it
              // so it doesn't fall through to the map.
            },
          );
        }
      },
      // opaque so pointer-down / drag events are caught by this subtree
      // (and its scrollable children) instead of passing to the map.
      behavior: HitTestBehavior.opaque,
      child: child,
    );
  }
}

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

    return _MapEventBlocker(
      child: Column(
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
      return _MapEventBlocker(child: timelinePanel);
    }

    return _MapEventBlocker(
      child: Column(
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
