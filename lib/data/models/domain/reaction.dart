import 'reaction_type.dart';

/// Reaction model
class Reaction {
  final String id;
  final String userId;
  final String username;
  final ReactionType type;
  final DateTime createdAt;

  Reaction({
    required this.id,
    required this.userId,
    required this.username,
    required this.type,
    required this.createdAt,
  });

  factory Reaction.fromJson(Map<String, dynamic> json) => Reaction(
    id: json['id'] as String,
    userId: json['userId'] as String,
    username: json['username'] as String,
    type: ReactionType.fromJson(json['type'] as String),
    createdAt: DateTime.parse(json['createdAt'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'username': username,
    'type': type.toJson(),
    'createdAt': createdAt.toIso8601String(),
  };
}
