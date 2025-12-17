import 'package:flutter/material.dart';
import 'package:tracker_frontend/data/models/comment_models.dart';
import 'package:tracker_frontend/presentation/screens/profile_screen.dart';
import 'package:tracker_frontend/presentation/helpers/page_transitions.dart';

/// Widget displaying a reply card
class ReplyCard extends StatelessWidget {
  final Comment reply;

  const ReplyCard({super.key, required this.reply});

  void _navigateToProfile(BuildContext context) {
    Navigator.push(
      context,
      PageTransitions.slideRight(
        ProfileScreen(userId: reply.userId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 32, top: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InkWell(
                onTap: () => _navigateToProfile(context),
                child: CircleAvatar(
                  radius: 12,
                  child: Text(
                    reply.username[0].toUpperCase(),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () => _navigateToProfile(context),
                      child: Text(
                        '@${reply.username}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    Text(
                      _formatTimestamp(reply.createdAt),
                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(reply.message, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}
