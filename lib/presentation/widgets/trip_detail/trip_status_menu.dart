import 'package:flutter/material.dart';
import 'package:tracker_frontend/core/constants/enums.dart';
import 'package:tracker_frontend/presentation/helpers/ui_helpers.dart';

/// AppBar actions for changing trip status
class TripStatusMenu extends StatelessWidget {
  final Function(TripStatus) onStatusChanged;

  const TripStatusMenu({super.key, required this.onStatusChanged});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<TripStatus>(
      icon: const Icon(Icons.more_vert),
      onSelected: onStatusChanged,
      itemBuilder: (context) => [
        PopupMenuItem(
          value: TripStatus.in_progress,
          child: Row(
            children: [
              Icon(
                UiHelpers.getStatusIcon(TripStatus.in_progress),
                color: Colors.green,
              ),
              const SizedBox(width: 8),
              const Text('Start Trip'),
            ],
          ),
        ),
        PopupMenuItem(
          value: TripStatus.paused,
          child: Row(
            children: [
              Icon(
                UiHelpers.getStatusIcon(TripStatus.paused),
                color: Colors.orange,
              ),
              const SizedBox(width: 8),
              const Text('Pause Trip'),
            ],
          ),
        ),
        PopupMenuItem(
          value: TripStatus.finished,
          child: Row(
            children: [
              Icon(
                UiHelpers.getStatusIcon(TripStatus.finished),
                color: Colors.grey,
              ),
              const SizedBox(width: 8),
              const Text('Finish Trip'),
            ],
          ),
        ),
      ],
    );
  }
}
