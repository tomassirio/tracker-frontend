/// Request to follow a user
class UserFollowRequest {
  final String followedId;

  UserFollowRequest({
    required this.followedId,
  });

  Map<String, dynamic> toJson() => {
        'followedId': followedId,
      };
}
