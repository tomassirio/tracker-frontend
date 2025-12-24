import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:tracker_frontend/data/models/comment_models.dart';
import 'package:tracker_frontend/presentation/widgets/trip_detail/comment_card.dart';
import 'package:tracker_frontend/presentation/widgets/trip_detail/comment_input.dart';
import 'package:tracker_frontend/core/theme/wanderer_theme.dart';

enum CommentSortOption { latest, oldest, mostReplies, mostReactions }

/// Widget displaying the full comments section with glassmorphism design
/// Supports collapsible bubble state
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
    if (isCollapsed) {
      return _buildCollapsedBubble();
    }
    return _buildExpandedSection();
  }

  /// Collapsed state - floating bubble with comment icon and count badge
  Widget _buildCollapsedBubble() {
    return Container(
      margin: const EdgeInsets.only(left: 16, bottom: 16),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: WandererTheme.floatingShadow,
      ),
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: WandererTheme.glassBlurSigma,
            sigmaY: WandererTheme.glassBlurSigma,
          ),
          child: Material(
            color: WandererTheme.glassBackground,
            shape: CircleBorder(
              side: BorderSide(
                color: WandererTheme.glassBorderColor,
                width: 1,
              ),
            ),
            child: InkWell(
              onTap: onToggleCollapse,
              customBorder: const CircleBorder(),
              child: Stack(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.chat_bubble_outline,
                      size: 24,
                      color: WandererTheme.primaryOrange,
                    ),
                  ),
                  // Badge with count
                  if (comments.isNotEmpty)
                    Positioned(
                      right: 4,
                      top: 4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: WandererTheme.primaryOrange,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Center(
                          child: Text(
                            comments.length > 99 ? '99+' : '${comments.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Expanded state - full comments section
  Widget _buildExpandedSection() {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(WandererTheme.glassRadius),
        boxShadow: WandererTheme.floatingShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(WandererTheme.glassRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: WandererTheme.glassBlurSigma,
            sigmaY: WandererTheme.glassBlurSigma,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: WandererTheme.glassBackground,
              borderRadius: BorderRadius.circular(WandererTheme.glassRadius),
              border: Border.all(
                color: WandererTheme.glassBorderColor,
                width: 1,
              ),
            ),
            child: Column(
              children: [
                // Comments section header with glass styling
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.4),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(WandererTheme.glassRadius),
                      topRight: Radius.circular(WandererTheme.glassRadius),
                    ),
                    border: Border(
                      bottom: BorderSide(
                        color: WandererTheme.glassBorderColor,
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 18,
                        color: WandererTheme.primaryOrange,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${comments.length} Comments',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: WandererTheme.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      PopupMenuButton<CommentSortOption>(
                        icon: Icon(
                          Icons.sort,
                          size: 20,
                          color: WandererTheme.textSecondary,
                        ),
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
                      const SizedBox(width: 4),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.remove,
                            size: 18,
                            color: WandererTheme.textSecondary,
                          ),
                          onPressed: onToggleCollapse,
                          tooltip: 'Minimize',
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ),
                // Comments list
                Expanded(
                  child: isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: WandererTheme.primaryOrange,
                          ),
                        )
                      : comments.isEmpty
                          ? _buildEmptyCommentsState()
                          : ListView.builder(
                              controller: scrollController,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              itemCount: comments.length,
                              itemBuilder: (context, index) {
                                final comment = comments[index];
                                final isExpanded =
                                    expandedComments[comment.id] ?? false;
                                final commentReplies =
                                    replies[comment.id] ?? [];

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
                      color: Colors.white.withOpacity(0.4),
                      border: Border(
                        top: BorderSide(
                          color: WandererTheme.glassBorderColor,
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Please log in to comment',
                        style: TextStyle(
                          color: WandererTheme.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCommentsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.comment_outlined,
              size: 64,
              color: WandererTheme.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              'No comments yet',
              style: TextStyle(
                fontSize: 18,
                color: WandererTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isLoggedIn
                  ? 'Be the first to comment!'
                  : 'Log in to add a comment',
              style: TextStyle(
                fontSize: 14,
                color: WandererTheme.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
