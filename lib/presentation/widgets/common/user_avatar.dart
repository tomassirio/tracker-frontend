import 'package:flutter/material.dart';
import '../../../core/theme/wanderer_theme.dart';

/// A reusable widget for displaying user avatars with fallback to initials
class UserAvatar extends StatelessWidget {
  final String? avatarUrl;
  final String username;
  final double radius;
  final Color? backgroundColor;
  final Color? textColor;

  const UserAvatar({
    super.key,
    this.avatarUrl,
    required this.username,
    this.radius = 16,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor =
        backgroundColor ?? WandererTheme.primaryOrange.withOpacity(0.15);
    final txtColor = textColor ?? WandererTheme.primaryOrange;

    // If avatar URL is provided and valid, use it
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: bgColor,
        backgroundImage: NetworkImage(avatarUrl!),
        onBackgroundImageError: (_, __) {
          // Fallback is handled by the child
        },
        child: _buildFallback(txtColor),
      );
    }

    // Fallback to username initial
    return CircleAvatar(
      radius: radius,
      backgroundColor: bgColor,
      child: _buildFallback(txtColor),
    );
  }

  Widget _buildFallback(Color txtColor) {
    return Text(
      username.isNotEmpty ? username[0].toUpperCase() : '?',
      style: TextStyle(
        color: txtColor,
        fontSize: radius * 0.5,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
