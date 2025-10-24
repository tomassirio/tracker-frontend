import 'package:flutter/material.dart' hide Visibility;
import 'package:tracker_frontend/core/constants/enums.dart';

/// Helper class for UI-related utilities
class UiHelpers {
  /// Gets the appropriate icon for a trip status
  static IconData getStatusIcon(TripStatus status) {
    switch (status) {
      case TripStatus.in_progress:
        return Icons.play_arrow;
      case TripStatus.created:
        return Icons.schedule;
      case TripStatus.paused:
        return Icons.pause;
      case TripStatus.finished:
        return Icons.check;
    }
  }

  /// Gets the appropriate icon for trip visibility
  static IconData getVisibilityIcon(Visibility visibility) {
    switch (visibility) {
      case Visibility.private:
        return Icons.lock;
      case Visibility.protected:
        return Icons.group;
      case Visibility.public:
        return Icons.public;
    }
  }

  /// Shows a success snackbar
  static void showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Shows an error snackbar
  static void showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
