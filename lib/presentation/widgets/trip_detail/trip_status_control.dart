import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:wanderer_frontend/core/constants/enums.dart';
import 'package:wanderer_frontend/core/theme/wanderer_theme.dart';

/// Widget for controlling trip status (start/pause/resume/finish)
/// Only shown on mobile (not web) and only for trip owners
class TripStatusControl extends StatelessWidget {
  final TripStatus currentStatus;
  final bool isOwner;
  final bool isLoading;
  final Function(TripStatus) onStatusChange;

  /// Whether running on web platform. Defaults to [kIsWeb].
  /// Can be overridden for testing purposes.
  final bool? isWeb;

  const TripStatusControl({
    super.key,
    required this.currentStatus,
    required this.isOwner,
    required this.isLoading,
    required this.onStatusChange,
    this.isWeb,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIsWeb = isWeb ?? kIsWeb;

    // Only show on mobile (not web)
    if (effectiveIsWeb) {
      return const SizedBox.shrink();
    }

    // Only show for trip owners
    if (!isOwner) {
      return const SizedBox.shrink();
    }

    // Don't show controls if trip is finished
    if (currentStatus == TripStatus.finished) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        if (currentStatus == TripStatus.created ||
            currentStatus == TripStatus.paused ||
            currentStatus == TripStatus.resting)
          _buildButton(
            context: context,
            label:
                currentStatus == TripStatus.created ? 'Start Trip' : 'Resume',
            icon: Icons.play_arrow,
            color: WandererTheme.statusCreated,
            onPressed: () => onStatusChange(TripStatus.inProgress),
          ),
        if (currentStatus == TripStatus.inProgress) ...[
          _buildButton(
            context: context,
            label: 'Pause',
            icon: Icons.pause,
            color: WandererTheme.statusInProgress,
            onPressed: () => onStatusChange(TripStatus.paused),
          ),
          const SizedBox(width: 8),
          _buildButton(
            context: context,
            label: 'Finish',
            icon: Icons.check,
            color: WandererTheme.statusCompleted,
            onPressed: () => _showFinishConfirmation(context),
          ),
        ],
      ],
    );
  }

  Widget _buildButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: const Size(0, 32),
        textStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Future<void> _showFinishConfirmation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Finish Trip'),
        content: const Text(
          'Are you sure you want to finish this trip? This will mark the trip as completed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            key: const Key('confirm_finish_button'),
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: WandererTheme.statusCompleted,
              foregroundColor: Colors.white,
            ),
            child: const Text('Finish'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      onStatusChange(TripStatus.finished);
    }
  }
}
