import 'package:flutter/material.dart';
import 'package:tracker_frontend/data/models/comment_models.dart';
import 'package:tracker_frontend/presentation/widgets/trip_detail/reply_card.dart';

/// Widget displaying a comment card with reactions and replies
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
    final isAuthor = comment.userId == tripUserId;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isAuthor ? Colors.blue[50] : Colors.white,
        border: Border.all(color: isAuthor ? Colors.blue[200]! : Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                child: Text(comment.username[0].toUpperCase()),
              ),
              const SizedBox(width: 8),
              Column(
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
                      if (isAuthor) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'AUTHOR',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    _formatTimestamp(comment.createdAt),
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            comment.message,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              InkWell(
                onTap: onReact,
                child: Row(
                  children: [
                    Icon(Icons.add_reaction_outlined, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${comment.reactionsCount}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              InkWell(
                onTap: onReply,
                child: Row(
                  children: [
                    Icon(Icons.reply, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    const Text(
                      'Reply',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (comment.responsesCount > 0) ...[
                const SizedBox(width: 16),
                InkWell(
                  onTap: onToggleReplies,
                  child: Row(
                    children: [
                      Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${comment.responsesCount} ${comment.responsesCount == 1 ? 'reply' : 'replies'}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          if (isExpanded && replies.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Divider(),
            ...replies.map((reply) => ReplyCard(reply: reply)),
          ],
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
