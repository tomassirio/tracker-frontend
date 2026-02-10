import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:tracker_frontend/core/constants/enums.dart';
import 'package:tracker_frontend/presentation/helpers/ui_helpers.dart';

/// Widget for controlling trip status (start/pause/resume/finish)
/// Only shown on mobile (not web) and only for trip owners
class TripStatusControl extends StatelessWidget {
  final TripStatus currentStatus;
  final bool isOwner;
  final bool isLoading;
  final Function(TripStatus) onStatusChange;

  const TripStatusControl({
    super.key,
    required this.currentStatus,
    required this.isOwner,
    required this.isLoading,
    required this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    // Only show on mobile (not web) and only for trip owners
    if (kIsWeb || !isOwner) {
      return const SizedBox.shrink();
    }

    // Don't show controls if trip is finished
    if (currentStatus == TripStatus.finished) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        if (currentStatus == TripStatus.created ||
            currentStatus == TripStatus.paused)
          _buildButton(
            context: context,
            label: currentStatus == TripStatus.created ? 'Start Trip' : 'Resume',
            icon: Icons.play_arrow,
            color: Colors.green,
            onPressed: () => onStatusChange(TripStatus.inProgress),
          ),
        if (currentStatus == TripStatus.inProgress) ...[
          _buildButton(
            context: context,
            label: 'Pause',
            icon: Icons.pause,
            color: Colors.orange,
            onPressed: () => onStatusChange(TripStatus.paused),
          ),
          const SizedBox(width: 8),
          _buildButton(
            context: context,
            label: 'Finish',
            icon: Icons.check,
            color: Colors.blue,
            onPressed: () => onStatusChange(TripStatus.finished),
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
}
