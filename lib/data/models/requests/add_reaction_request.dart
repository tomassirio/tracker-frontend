import '../domain/reaction_type.dart';

/// Request model for adding a reaction
class AddReactionRequest {
  final ReactionType reactionType;

  AddReactionRequest({required this.reactionType});

  Map<String, dynamic> toJson() => {
        'reactionType': reactionType.toJson(),
      };
}

