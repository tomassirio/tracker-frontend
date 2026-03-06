import 'package:flutter/material.dart';
import 'package:wanderer_frontend/core/routing/route_strategy.dart';
import 'package:wanderer_frontend/presentation/screens/privacy_policy_screen.dart';

/// Handles `/privacy-policy` → PrivacyPolicyScreen.
class PrivacyPolicyRouteStrategy implements RouteStrategy {
  @override
  bool matches(Uri uri) => uri.path == '/privacy-policy';

  @override
  MaterialPageRoute build(Uri uri, RouteSettings settings) {
    return MaterialPageRoute(
      settings: settings,
      builder: (context) => const PrivacyPolicyScreen(),
    );
  }
}

