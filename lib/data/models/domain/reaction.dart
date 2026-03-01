import 'reaction_type.dart';

/// Reaction model for individual reactions on comments
class Reaction {
  final String userId;
  final String username;
  final ReactionType reactionType;
  final DateTime timestamp;

  Reaction({
    required this.userId,
    required this.username,
    required this.reactionType,
    required this.timestamp,
  });

  factory Reaction.fromJson(Map<String, dynamic> json) => Reaction(
        userId: json['userId'] as String,
        username: json['username'] as String,
        reactionType: ReactionType.fromJson(json['reactionType'] as String),
        timestamp: DateTime.parse(json['timestamp'] as String),
      );

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'username': username,
        'reactionType': reactionType.toJson(),
        'timestamp': timestamp.toIso8601String(),
      };
}
