import 'reaction_type.dart';

/// Reaction model for individual reactions on comments
class Reaction {
  final String userId;
  final String username;
  final ReactionType type;
  final DateTime timestamp;

  Reaction({
    required this.userId,
    required this.username,
    required this.type,
    required this.timestamp,
  });

  factory Reaction.fromJson(Map<String, dynamic> json) => Reaction(
        userId: json['userId'] as String,
        username: json['username'] as String,
        type: ReactionType.fromJson(json['reactionType'] as String),
        timestamp: DateTime.parse(json['timestamp'] as String),
      );

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'username': username,
        'reactionType': type.toJson(),
        'timestamp': timestamp.toIso8601String(),
      };
}
