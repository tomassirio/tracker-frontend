import 'package:flutter/material.dart';

/// Custom page route transitions inspired by Binding of Isaac's retro menu style
/// These transitions ensure proper bidirectional movement for a cohesive spatial layout:
/// - Profile is to the right of Trips
/// - Trip Plans is to the left of Trips
/// - Trip Details are below Trips
class PageTransitions {
  static const Duration _transitionDuration = Duration(milliseconds: 250);

  /// Navigate to profile (slides in from right, exits to right)
  static PageRouteBuilder slideRight(Widget page) {
    return PageRouteBuilder(
      transitionDuration: _transitionDuration,
      reverseTransitionDuration: _transitionDuration,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slideAnimation =
            Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
                reverseCurve: Curves.easeInCubic,
              ),
            );

        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));

        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(opacity: fadeAnimation, child: child),
        );
      },
    );
  }

  /// Navigate to trip plans (slides in from left, exits to left)
  static PageRouteBuilder slideLeft(Widget page) {
    return PageRouteBuilder(
      transitionDuration: _transitionDuration,
      reverseTransitionDuration: _transitionDuration,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slideAnimation =
            Tween<Offset>(
              begin: const Offset(-1.0, 0.0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
                reverseCurve: Curves.easeInCubic,
              ),
            );

        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));

        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(opacity: fadeAnimation, child: child),
        );
      },
    );
  }

  /// Navigate to trip details (slides up from bottom, exits down)
  static PageRouteBuilder slideUp(Widget page) {
    return PageRouteBuilder(
      transitionDuration: _transitionDuration,
      reverseTransitionDuration: _transitionDuration,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slideAnimation =
            Tween<Offset>(
              begin: const Offset(0.0, 1.0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
                reverseCurve: Curves.easeInCubic,
              ),
            );

        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));

        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(opacity: fadeAnimation, child: child),
        );
      },
    );
  }
}
