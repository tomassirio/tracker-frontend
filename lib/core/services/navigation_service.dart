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
  /// Uses push so user can go back to previous screen after login
  void navigateToAuth() {
    final context = navigatorKey.currentContext;
    if (context != null) {
      Navigator.of(context).pushNamed('/auth');
    }
  }

  /// Navigate to auth and clear all routes (for explicit logout)
  void navigateToAuthAndClearStack() {
    final context = navigatorKey.currentContext;
    if (context != null) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/auth',
        (route) => false,
      );
    }
  }

  /// Get current navigation context
  BuildContext? get context => navigatorKey.currentContext;
}
