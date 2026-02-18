/// Friend request model
class FriendRequest {
  final String id;
  final String senderId;
  final String receiverId;
  final FriendRequestStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  FriendRequest({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    return FriendRequest(
      // Use empty strings as fallback for consistency with UserProfile pattern
      id: json['id'] as String? ?? '',
      senderId: json['senderId'] as String? ?? '',
      receiverId: json['receiverId'] as String? ?? '',
      status: FriendRequestStatus.fromString(
          json['status'] as String? ?? 'PENDING'),
      // Use DateTime.now() as fallback for consistency with existing models
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'senderId': senderId,
        'receiverId': receiverId,
        'status': status.toJson(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}

/// Friend request status enum
enum FriendRequestStatus {
  pending,
  accepted,
  declined;

  static FriendRequestStatus fromString(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return FriendRequestStatus.pending;
      case 'ACCEPTED':
        return FriendRequestStatus.accepted;
      case 'DECLINED':
        return FriendRequestStatus.declined;
      default:
        return FriendRequestStatus.pending;
    }
  }

  String toJson() {
    switch (this) {
      case FriendRequestStatus.pending:
        return 'PENDING';
      case FriendRequestStatus.accepted:
        return 'ACCEPTED';
      case FriendRequestStatus.declined:
        return 'DECLINED';
    }
  }
}
