import 'package:flutter/material.dart';
import 'package:tracker_frontend/data/models/comment_models.dart';
import 'package:tracker_frontend/presentation/widgets/trip_detail/comment_card.dart';
import 'package:tracker_frontend/presentation/widgets/trip_detail/comment_input.dart';

enum CommentSortOption { latest, oldest, mostReplies, mostReactions }

/// Widget displaying the full comments section with header, list, and input
class CommentsSection extends StatelessWidget {
  final List<Comment> comments;
  final Map<String, List<Comment>> replies;
  final Map<String, bool> expandedComments;
  final String tripUserId;
  final bool isLoading;
  final bool isLoggedIn;
  final bool isAddingComment;
  final bool isCollapsed;
  final CommentSortOption sortOption;
  final TextEditingController commentController;
  final ScrollController scrollController;
  final String? replyingToCommentId;
  final VoidCallback onToggleCollapse;
  final Function(CommentSortOption) onSortChanged;
  final Function(String) onReact;
  final Function(String) onReply;
  final Function(String, bool) onToggleReplies;
  final VoidCallback onSendComment;
  final VoidCallback onCancelReply;

  const CommentsSection({
    super.key,
    required this.comments,
    required this.replies,
    required this.expandedComments,
    required this.tripUserId,
    required this.isLoading,
    required this.isLoggedIn,
    required this.isAddingComment,
    required this.isCollapsed,
    required this.sortOption,
    required this.commentController,
    required this.scrollController,
    this.replyingToCommentId,
    required this.onToggleCollapse,
    required this.onSortChanged,
    required this.onReact,
    required this.onReply,
    required this.onToggleReplies,
    required this.onSendComment,
    required this.onCancelReply,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Comments section header with sort options
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
          ),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  isCollapsed ? Icons.expand_more : Icons.expand_less,
                  size: 20,
                ),
                onPressed: onToggleCollapse,
                tooltip: isCollapsed ? 'Expand comments' : 'Collapse comments',
              ),
              const SizedBox(width: 8),
              Text(
                '${comments.length} Comments',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (!isCollapsed)
                PopupMenuButton<CommentSortOption>(
                  icon: const Icon(Icons.sort),
                  onSelected: onSortChanged,
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: CommentSortOption.latest,
                      child: Text('Latest first'),
                    ),
                    const PopupMenuItem(
                      value: CommentSortOption.oldest,
                      child: Text('Oldest first'),
                    ),
                    const PopupMenuItem(
                      value: CommentSortOption.mostReplies,
                      child: Text('Most replies'),
                    ),
                    const PopupMenuItem(
                      value: CommentSortOption.mostReactions,
                      child: Text('Most reactions'),
                    ),
                  ],
                ),
            ],
          ),
        ),
        // Comments list - only show when not collapsed
        if (!isCollapsed) ...[
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : comments.isEmpty
                ? _buildEmptyCommentsState()
                : ListView.builder(
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
                        onToggleReplies: () =>
                            onToggleReplies(comment.id, isExpanded),
                      );
                    },
                  ),
          ),
          // Comment input (disabled if not logged in)
          if (isLoggedIn)
            CommentInput(
              controller: commentController,
              isAddingComment: isAddingComment,
              isReplyMode: replyingToCommentId != null,
              onSend: onSendComment,
              onCancelReply: onCancelReply,
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              child: const Center(
                child: Text(
                  'Please log in to comment',
                  style: TextStyle(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildEmptyCommentsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.comment_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No comments yet',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              isLoggedIn
                  ? 'Be the first to comment!'
                  : 'Log in to add a comment',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}
