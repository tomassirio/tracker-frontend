import 'package:flutter/material.dart';

/// Widget for input field to add comments
class CommentInput extends StatelessWidget {
  final TextEditingController controller;
  final bool isAddingComment;
  final bool isReplyMode;
  final VoidCallback onSend;
  final VoidCallback onCancelReply;

  const CommentInput({
    super.key,
    required this.controller,
    required this.isAddingComment,
    required this.isReplyMode,
    required this.onSend,
    required this.onCancelReply,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isReplyMode) ...[
            Row(
              children: [
                const Icon(Icons.reply, size: 16),
                const SizedBox(width: 8),
                const Text(
                  'Replying to comment',
                  style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  onPressed: onCancelReply,
                  tooltip: 'Cancel reply',
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: isReplyMode ? 'Write a reply...' : 'Write a comment...',
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => onSend(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: isAddingComment
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                onPressed: isAddingComment ? null : onSend,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
