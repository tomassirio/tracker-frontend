import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:tracker_frontend/presentation/strategies/trip_detail_layout_strategy.dart';

/// Prevents mouse-wheel (pointer signal) events from passing through a panel
/// to the Google Map sitting behind it in the widget Stack.
///
/// How it works: Flutter dispatches [PointerScrollEvent]s through a
/// [PointerSignalResolver]. If nobody claims the event, it falls through to
/// every widget in the hit-test path — including the map. By registering a
/// no-op handler we ensure the event is "claimed" and the map never sees it.
///
/// Click-and-drag is **not** intercepted here. The panel's own scrollable
/// children (ListView, SingleChildScrollView, etc.) naturally win the gesture
/// arena because they sit higher in the hit-test order than the map.
class _MapScrollBlocker extends StatelessWidget {
  final Widget child;

  const _MapScrollBlocker({required this.child});

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: (PointerSignalEvent event) {
        if (event is PointerScrollEvent) {
          GestureBinding.instance.pointerSignalResolver.register(
            event,
            (_) {},
          );
        }
      },
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

    return _MapScrollBlocker(
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
      return _MapScrollBlocker(child: timelinePanel);
    }

    return _MapScrollBlocker(
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
