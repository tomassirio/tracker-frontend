import 'package:flutter/material.dart';

/// Custom page route transitions inspired by Binding of Isaac's retro menu style
/// These transitions ensure proper bidirectional movement for a cohesive spatial layout:
/// - Profile is to the right of Trips
/// - Trip Plans is to the left of Trips
/// - Trip Details are below Trips
class PageTransitions {
  static const Duration _transitionDuration = Duration(milliseconds: 300);
  static const Curve _curve = Curves.easeInOut;

  static Animation<Offset> _createSlideAnimation(
    Animation<double> animation,
    Offset begin,
  ) {
    return Tween<Offset>(
      begin: begin,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: _curve));
  }

  static Animation<double> _createFadeAnimation(Animation<double> animation) {
    return Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.linear));
  }

  /// Navigate to profile (slides in from right, exits to right)
  static PageRouteBuilder slideRight(Widget page) {
    return PageRouteBuilder(
      transitionDuration: _transitionDuration,
      reverseTransitionDuration: _transitionDuration,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: _createSlideAnimation(animation, const Offset(1.0, 0.0)),
          child: FadeTransition(
            opacity: _createFadeAnimation(animation),
            child: child,
          ),
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
        return SlideTransition(
          position: _createSlideAnimation(animation, const Offset(-1.0, 0.0)),
          child: FadeTransition(
            opacity: _createFadeAnimation(animation),
            child: child,
          ),
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
        final slideAnimation = Tween<Offset>(
          begin: const Offset(0.0, 1.0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: animation, curve: Curves.fastOutSlowIn),
        );

        final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
          ),
        );

        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(opacity: fadeAnimation, child: child),
        );
      },
    );
  }
}
