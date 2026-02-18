import 'package:flutter/material.dart';

/// Badge widget that displays relationship with the trip owner
class RelationshipBadge extends StatelessWidget {
  final RelationshipType type;
  final bool compact;

  const RelationshipBadge({
    super.key,
    required this.type,
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
    switch (type) {
      case RelationshipType.friend:
        return Icons.people;
      case RelationshipType.following:
        return Icons.person_add_alt_1;
    }
  }

  String _getLabel() {
    switch (type) {
      case RelationshipType.friend:
        return 'Friend';
      case RelationshipType.following:
        return 'Following';
    }
  }

  Color _getBackgroundColor() {
    switch (type) {
      case RelationshipType.friend:
        return Colors.blue.withOpacity(0.1);
      case RelationshipType.following:
        return Colors.purple.withOpacity(0.1);
    }
  }

  Color _getBorderColor() {
    switch (type) {
      case RelationshipType.friend:
        return Colors.blue.withOpacity(0.3);
      case RelationshipType.following:
        return Colors.purple.withOpacity(0.3);
    }
  }

  Color _getIconColor() {
    switch (type) {
      case RelationshipType.friend:
        return Colors.blue.shade700;
      case RelationshipType.following:
        return Colors.purple.shade700;
    }
  }
}

enum RelationshipType {
  friend,
  following,
}
