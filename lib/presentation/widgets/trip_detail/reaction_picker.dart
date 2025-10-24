import 'package:flutter/material.dart';

import '../../../data/models/domain/reaction_type.dart';

/// A bottom sheet widget for picking reactions
class ReactionPicker extends StatelessWidget {
  final Function(ReactionType) onReactionSelected;

  const ReactionPicker({super.key, required this.onReactionSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'React to this comment',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ReactionButton(
                emoji: '❤️',
                type: ReactionType.heart,
                onTap: () {
                  Navigator.pop(context);
                  onReactionSelected(ReactionType.heart);
                },
              ),
              _ReactionButton(
                emoji: '😊',
                type: ReactionType.smiley,
                onTap: () {
                  Navigator.pop(context);
                  onReactionSelected(ReactionType.smiley);
                },
              ),
              _ReactionButton(
                emoji: '😥',
                type: ReactionType.sad,
                onTap: () {
                  Navigator.pop(context);
                  onReactionSelected(ReactionType.sad);
                },
              ),
              _ReactionButton(
                emoji: '😂',
                type: ReactionType.laugh,
                onTap: () {
                  Navigator.pop(context);
                  onReactionSelected(ReactionType.laugh);
                },
              ),
              _ReactionButton(
                emoji: '😠',
                type: ReactionType.anger,
                onTap: () {
                  Navigator.pop(context);
                  onReactionSelected(ReactionType.anger);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _ReactionButton extends StatelessWidget {
  final String emoji;
  final ReactionType type;
  final VoidCallback onTap;

  const _ReactionButton({
    required this.emoji,
    required this.type,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(25),
        ),
        child: Center(child: Text(emoji, style: const TextStyle(fontSize: 28))),
      ),
    );
  }
}
