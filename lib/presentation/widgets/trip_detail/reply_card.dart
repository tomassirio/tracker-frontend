import 'package:flutter/material.dart';
import 'package:tracker_frontend/data/models/comment_models.dart';

/// A card widget displaying a reply to a comment
class ReplyCard extends StatelessWidget {
  final Comment reply;
  final String tripUserId;

  const ReplyCard({
    super.key,
    required this.reply,
    required this.tripUserId,
  });

  @override
  Widget build(BuildContext context) {
    final isOwner = reply.userId == tripUserId;

    return Container(
      margin: const EdgeInsets.only(left: 24, top: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isOwner ? Colors.amber[100] : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: isOwner ? Colors.amber : Colors.blue,
                child: Text(
                  reply.username[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Row(
                  children: [
                    Text(
                      reply.username,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    if (isOwner) ...[
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.star,
                        size: 12,
                        color: Colors.amber,
                      ),
                    ],
                    const SizedBox(width: 8),
                    Text(
                      _formatDateTime(reply.createdAt),
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            reply.message,
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

