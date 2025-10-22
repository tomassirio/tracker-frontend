import '../domain/reaction_type.dart';

/// Request model for adding a reaction
class AddReactionRequest {
  final ReactionType type;

  AddReactionRequest({required this.type});

  Map<String, dynamic> toJson() => {
        'type': type.toJson(),
      };
}

