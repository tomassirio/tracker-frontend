import 'package:flutter/material.dart';
import 'package:tracker_frontend/data/models/trip_models.dart';

/// Badge widget that displays trip status with live indicator
class StatusBadge extends StatefulWidget {
  final TripStatus status;
  final bool compact;

  const StatusBadge({
    super.key,
    required this.status,
    this.compact = false,
  });

  @override
  State<StatusBadge> createState() => _StatusBadgeState();
}

class _StatusBadgeState extends State<StatusBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    if (widget.status == TripStatus.IN_PROGRESS) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(StatusBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.status == TripStatus.IN_PROGRESS &&
        oldWidget.status != TripStatus.IN_PROGRESS) {
      _pulseController.repeat(reverse: true);
    } else if (widget.status != TripStatus.IN_PROGRESS &&
        oldWidget.status == TripStatus.IN_PROGRESS) {
      _pulseController.stop();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.compact
          ? const EdgeInsets.symmetric(horizontal: 6, vertical: 2)
          : const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getBorderColor(), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.status == TripStatus.IN_PROGRESS)
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Container(
                  width: widget.compact ? 6 : 8,
                  height: widget.compact ? 6 : 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getIconColor(),
                    boxShadow: [
                      BoxShadow(
                        color: _getIconColor().withOpacity(_pulseController.value),
                        blurRadius: 4,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                );
              },
            )
          else
            Icon(
              _getIcon(),
              size: widget.compact ? 12 : 14,
              color: _getIconColor(),
            ),
          if (!widget.compact) ...[
            const SizedBox(width: 4),
            Text(
              _getLabel(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _getIconColor(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getIcon() {
    switch (widget.status) {
      case TripStatus.CREATED:
        return Icons.edit_outlined;
      case TripStatus.IN_PROGRESS:
        return Icons.circle;
      case TripStatus.PAUSED:
        return Icons.pause;
      case TripStatus.FINISHED:
        return Icons.check_circle_outline;
    }
  }

  String _getLabel() {
    switch (widget.status) {
      case TripStatus.CREATED:
        return 'Draft';
      case TripStatus.IN_PROGRESS:
        return 'Live';
      case TripStatus.PAUSED:
        return 'Paused';
      case TripStatus.FINISHED:
        return 'Completed';
    }
  }

  Color _getBackgroundColor() {
    switch (widget.status) {
      case TripStatus.CREATED:
        return Colors.grey.withOpacity(0.1);
      case TripStatus.IN_PROGRESS:
        return Colors.green.withOpacity(0.1);
      case TripStatus.PAUSED:
        return Colors.orange.withOpacity(0.1);
      case TripStatus.FINISHED:
        return Colors.blue.withOpacity(0.1);
    }
  }

  Color _getBorderColor() {
    switch (widget.status) {
      case TripStatus.CREATED:
        return Colors.grey.withOpacity(0.3);
      case TripStatus.IN_PROGRESS:
        return Colors.green.withOpacity(0.3);
      case TripStatus.PAUSED:
        return Colors.orange.withOpacity(0.3);
      case TripStatus.FINISHED:
        return Colors.blue.withOpacity(0.3);
    }
  }

  Color _getIconColor() {
    switch (widget.status) {
      case TripStatus.CREATED:
        return Colors.grey.shade700;
      case TripStatus.IN_PROGRESS:
        return Colors.green.shade700;
      case TripStatus.PAUSED:
        return Colors.orange.shade700;
      case TripStatus.FINISHED:
        return Colors.blue.shade700;
    }
  }
}
