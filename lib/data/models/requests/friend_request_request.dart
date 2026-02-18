/// Request to send a friend request
class FriendRequestRequest {
  final String receiverId;

  FriendRequestRequest({
    required this.receiverId,
  });

  Map<String, dynamic> toJson() => {
        'receiverId': receiverId,
      };
}
