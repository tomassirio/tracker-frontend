import 'package:flutter/material.dart';
import 'package:tracker_frontend/data/models/trip_models.dart';

/// Badge widget that displays trip visibility status
class VisibilityBadge extends StatelessWidget {
  final Visibility visibility;
  final bool compact;

  const VisibilityBadge({
    super.key,
    required this.visibility,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: compact
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
          Icon(
            _getIcon(),
            size: compact ? 12 : 14,
            color: _getIconColor(),
          ),
          if (!compact) ...[
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
    switch (visibility) {
      case Visibility.PUBLIC:
        return Icons.public;
      case Visibility.PROTECTED:
        return Icons.lock_outline;
      case Visibility.PRIVATE:
        return Icons.lock;
    }
  }

  String _getLabel() {
    switch (visibility) {
      case Visibility.PUBLIC:
        return 'Public';
      case Visibility.PROTECTED:
        return 'Protected';
      case Visibility.PRIVATE:
        return 'Private';
    }
  }

  Color _getBackgroundColor() {
    switch (visibility) {
      case Visibility.PUBLIC:
        return Colors.green.withOpacity(0.1);
      case Visibility.PROTECTED:
        return Colors.orange.withOpacity(0.1);
      case Visibility.PRIVATE:
        return Colors.red.withOpacity(0.1);
    }
  }

  Color _getBorderColor() {
    switch (visibility) {
      case Visibility.PUBLIC:
        return Colors.green.withOpacity(0.3);
      case Visibility.PROTECTED:
        return Colors.orange.withOpacity(0.3);
      case Visibility.PRIVATE:
        return Colors.red.withOpacity(0.3);
    }
  }

  Color _getIconColor() {
    switch (visibility) {
      case Visibility.PUBLIC:
        return Colors.green.shade700;
      case Visibility.PROTECTED:
        return Colors.orange.shade700;
      case Visibility.PRIVATE:
        return Colors.red.shade700;
    }
  }
}
