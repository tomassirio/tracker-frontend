import 'package:flutter/material.dart';

/// Global navigation service for handling navigation from non-widget contexts
/// Primarily used for handling 401 errors and redirecting to auth screen
class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Navigate to the authentication screen
  /// Called when user receives 401 Unauthorized response
  void navigateToAuth() {
    final context = navigatorKey.currentContext;
    if (context != null) {
      // Import auth screen lazily to avoid circular dependencies
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/auth',
        (route) => false,
      );
    }
  }

  /// Get current navigation context
  BuildContext? get context => navigatorKey.currentContext;
}
