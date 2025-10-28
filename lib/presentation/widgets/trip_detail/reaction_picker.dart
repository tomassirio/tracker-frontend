import 'package:flutter/material.dart';
import 'package:tracker_frontend/data/models/comment_models.dart';

/// Modal bottom sheet for selecting reactions
class ReactionPicker extends StatelessWidget {
  final Function(ReactionType) onReactionSelected;

  const ReactionPicker({super.key, required this.onReactionSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Choose a reaction',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: [
              _ReactionButton(
                emoji: '❤️',
                label: 'Heart',
                type: ReactionType.heart,
                onTap: () {
                  onReactionSelected(ReactionType.heart);
                  Navigator.pop(context);
                },
              ),
              _ReactionButton(
                emoji: '😊',
                label: 'Smiley',
                type: ReactionType.smiley,
                onTap: () {
                  onReactionSelected(ReactionType.smiley);
                  Navigator.pop(context);
                },
              ),
              _ReactionButton(
                emoji: '😂',
                label: 'Laugh',
                type: ReactionType.laugh,
                onTap: () {
                  onReactionSelected(ReactionType.laugh);
                  Navigator.pop(context);
                },
              ),
              _ReactionButton(
                emoji: '😢',
                label: 'Sad',
                type: ReactionType.sad,
                onTap: () {
                  onReactionSelected(ReactionType.sad);
                  Navigator.pop(context);
                },
              ),
              _ReactionButton(
                emoji: '😡',
                label: 'Anger',
                type: ReactionType.anger,
                onTap: () {
                  onReactionSelected(ReactionType.anger);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReactionButton extends StatelessWidget {
  final String emoji;
  final String label;
  final ReactionType type;
  final VoidCallback onTap;

  const _ReactionButton({
    required this.emoji,
    required this.label,
    required this.type,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
