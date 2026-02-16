/// User follow relationship model
class UserFollow {
  final String id;
  final String followerId;
  final String followedId;
  final DateTime createdAt;

  UserFollow({
    required this.id,
    required this.followerId,
    required this.followedId,
    required this.createdAt,
  });

  factory UserFollow.fromJson(Map<String, dynamic> json) {
    return UserFollow(
      id: json['id'] as String? ?? '',
      followerId: json['followerId'] as String? ?? '',
      followedId: json['followedId'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'followerId': followerId,
        'followedId': followedId,
        'createdAt': createdAt.toIso8601String(),
      };
}
