import 'package:flutter/material.dart';
import 'package:wanderer_frontend/core/routing/route_strategy.dart';
import 'package:wanderer_frontend/presentation/screens/trip_deep_link_screen.dart';

/// Handles `/trip/:tripId` → TripDeepLinkScreen which loads the trip
/// by ID and then navigates to TripDetailScreen.
class TripRouteStrategy implements RouteStrategy {
  @override
  bool matches(Uri uri) =>
      uri.pathSegments.length == 2 && uri.pathSegments[0] == 'trip';

  @override
  MaterialPageRoute build(Uri uri, RouteSettings settings) {
    final tripId = uri.pathSegments[1];
    return MaterialPageRoute(
      settings: settings,
      builder: (context) => TripDeepLinkScreen(tripId: tripId),
    );
  }
}
