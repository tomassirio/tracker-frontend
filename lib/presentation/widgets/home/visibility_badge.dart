import 'package:flutter/material.dart' hide Visibility;
import 'package:tracker_frontend/core/constants/enums.dart' show Visibility;

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
      case Visibility.public:
        return Icons.public;
      case Visibility.protected:
        return Icons.lock_outline;
      case Visibility.private:
        return Icons.lock;
    }
  }

  String _getLabel() {
    switch (visibility) {
      case Visibility.public:
        return 'Public';
      case Visibility.protected:
        return 'Protected';
      case Visibility.private:
        return 'Private';
    }
  }

  Color _getBackgroundColor() {
    switch (visibility) {
      case Visibility.public:
        return Colors.green.withOpacity(0.1);
      case Visibility.protected:
        return Colors.orange.withOpacity(0.1);
      case Visibility.private:
        return Colors.red.withOpacity(0.1);
    }
  }

  Color _getBorderColor() {
    switch (visibility) {
      case Visibility.public:
        return Colors.green.withOpacity(0.3);
      case Visibility.protected:
        return Colors.orange.withOpacity(0.3);
      case Visibility.private:
        return Colors.red.withOpacity(0.3);
    }
  }

  Color _getIconColor() {
    switch (visibility) {
      case Visibility.public:
        return Colors.green.shade700;
      case Visibility.protected:
        return Colors.orange.shade700;
      case Visibility.private:
        return Colors.red.shade700;
    }
  }
}
