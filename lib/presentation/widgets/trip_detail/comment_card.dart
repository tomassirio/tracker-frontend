import 'package:flutter/material.dart';
import 'package:tracker_frontend/data/models/comment_models.dart';
import 'reply_card.dart';

/// A card widget displaying a single comment with reactions and replies
class CommentCard extends StatelessWidget {
  final Comment comment;
  final String tripUserId;
  final bool isExpanded;
  final List<Comment> replies;
  final VoidCallback onReact;
  final VoidCallback onReply;
  final VoidCallback onToggleReplies;

  const CommentCard({
    super.key,
    required this.comment,
    required this.tripUserId,
    required this.isExpanded,
    required this.replies,
    required this.onReact,
    required this.onReply,
    required this.onToggleReplies,
  });

  @override
  Widget build(BuildContext context) {
    final isOwner = comment.userId == tripUserId;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: isOwner ? Colors.amber[50] : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Comment header
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: isOwner ? Colors.amber : Colors.blue,
                  child: Text(
                    comment.username[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            comment.username,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          if (isOwner) ...[
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Owner',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.amber[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        _formatDateTime(comment.createdAt),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Comment message
            Text(comment.message, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 8),
            // Comment actions
            Row(
              children: [
                // Reaction button
                TextButton.icon(
                  onPressed: onReact,
                  icon: const Icon(Icons.thumb_up_outlined, size: 16),
                  label: Text(
                    comment.reactionsCount > 0
                        ? '${comment.reactionsCount}'
                        : 'React',
                    style: const TextStyle(fontSize: 12),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                const SizedBox(width: 8),
                // Reply button
                TextButton.icon(
                  onPressed: onReply,
                  icon: const Icon(Icons.reply, size: 16),
                  label: const Text('Reply', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                if (comment.responsesCount > 0) ...[
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: onToggleReplies,
                    icon: Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      size: 16,
                    ),
                    label: Text(
                      '${comment.responsesCount} ${comment.responsesCount == 1 ? 'reply' : 'replies'}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ],
            ),
            // Replies
            if (isExpanded && replies.isNotEmpty) ...[
              const Divider(),
              ...replies.map(
                (reply) => ReplyCard(reply: reply, tripUserId: tripUserId),
              ),
            ],
          ],
        ),
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
