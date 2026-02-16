/// Friendship model (bidirectional friendship)
class Friendship {
  final String userId;
  final String friendId;

  Friendship({
    required this.userId,
    required this.friendId,
  });

  factory Friendship.fromJson(Map<String, dynamic> json) {
    return Friendship(
      userId: json['userId'] as String? ?? '',
      friendId: json['friendId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'friendId': friendId,
      };
}
