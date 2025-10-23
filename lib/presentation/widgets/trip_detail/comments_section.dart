import 'package:flutter/material.dart';
import 'package:tracker_frontend/data/models/comment_models.dart';
import 'package:tracker_frontend/presentation/widgets/trip_detail/comment_card.dart';

/// Widget displaying the comments section with header and list
class CommentsSection extends StatelessWidget {
  final bool isLoading;
  final List<Comment> comments;
  final Map<String, bool> expandedComments;
  final Map<String, List<Comment>> replies;
  final String tripUserId;
  final ScrollController scrollController;
  final Function(String) onReact;
  final Function(String) onReply;
  final Function(String, bool) onToggleReplies;

  const CommentsSection({
    super.key,
    required this.isLoading,
    required this.comments,
    required this.expandedComments,
    required this.replies,
    required this.tripUserId,
    required this.scrollController,
    required this.onReact,
    required this.onReply,
    required this.onToggleReplies,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Comments header
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            border: Border(
              bottom: BorderSide(color: Colors.grey[300]!),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.comment, size: 20),
              const SizedBox(width: 8),
              Text(
                'Comments (${comments.length})',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
        // Comments list
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : comments.isEmpty
                  ? _buildEmptyState()
                  : _buildCommentsList(),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.comment_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No comments yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to comment!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsList() {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: comments.length,
      itemBuilder: (context, index) {
        final comment = comments[index];
        final isExpanded = expandedComments[comment.id] ?? false;
        final commentReplies = replies[comment.id] ?? [];

        return CommentCard(
          comment: comment,
          tripUserId: tripUserId,
          isExpanded: isExpanded,
          replies: commentReplies,
          onReact: () => onReact(comment.id),
          onReply: () => onReply(comment.id),
          onToggleReplies: () => onToggleReplies(comment.id, isExpanded),
        );
      },
    );
  }
}

