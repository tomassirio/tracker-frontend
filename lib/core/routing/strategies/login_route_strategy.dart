import 'package:flutter/material.dart';
import 'package:tracker_frontend/core/routing/route_strategy.dart';
import 'package:tracker_frontend/presentation/screens/auth_screen.dart';

/// Handles `/login` and `/auth` → AuthScreen (login mode).
class LoginRouteStrategy implements RouteStrategy {
  @override
  bool matches(Uri uri) =>
      uri.path == '/login' || uri.path == '/auth';

  @override
  MaterialPageRoute build(Uri uri, RouteSettings settings) {
    return MaterialPageRoute(
      settings: settings,
      builder: (context) => const AuthScreen(),
    );
  }
}

