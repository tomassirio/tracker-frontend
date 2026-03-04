import 'package:flutter/material.dart';
import 'package:tracker_frontend/core/routing/route_strategy.dart';
import 'package:tracker_frontend/presentation/screens/verify_email_screen.dart';

/// Handles `/verify-email` → VerifyEmailScreen.
class VerifyEmailRouteStrategy implements RouteStrategy {
  @override
  bool matches(Uri uri) => uri.path == '/verify-email';

  @override
  MaterialPageRoute build(Uri uri, RouteSettings settings) {
    return MaterialPageRoute(
      settings: settings,
      builder: (context) => const VerifyEmailScreen(),
    );
  }
}

