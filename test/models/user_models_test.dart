import 'package:flutter_test/flutter_test.dart';
import 'package:tracker_frontend/data/models/user_models.dart';

void main() {
  group('UserModels', () {
    group('FriendRequest', () {
      test('fromJson creates FriendRequest from JSON', () {
        final json = {
          'id': 'request-123',
          'senderId': 'user-456',
          'receiverId': 'user-789',
          'status': 'PENDING',
          'createdAt': '2024-01-15T10:30:00Z',
          'updatedAt': '2024-01-15T10:30:00Z',
        };

        final friendRequest = FriendRequest.fromJson(json);

        expect(friendRequest.id, 'request-123');
        expect(friendRequest.senderId, 'user-456');
        expect(friendRequest.receiverId, 'user-789');
        expect(friendRequest.status, FriendRequestStatus.pending);
        expect(friendRequest.createdAt.year, 2024);
        expect(friendRequest.updatedAt.year, 2024);
      });

      test('toJson converts FriendRequest correctly', () {
        final friendRequest = FriendRequest(
          id: 'request-123',
          senderId: 'user-456',
          receiverId: 'user-789',
          status: FriendRequestStatus.accepted,
          createdAt: DateTime.parse('2024-01-15T10:30:00Z'),
          updatedAt: DateTime.parse('2024-01-15T10:30:00Z'),
        );

        final json = friendRequest.toJson();

        expect(json['id'], 'request-123');
        expect(json['senderId'], 'user-456');
        expect(json['receiverId'], 'user-789');
        expect(json['status'], 'ACCEPTED');
        expect(json['createdAt'], '2024-01-15T10:30:00.000Z');
      });

      test('handles different status values', () {
        final pendingJson = {'status': 'PENDING'};
        final acceptedJson = {'status': 'ACCEPTED'};
        final declinedJson = {'status': 'DECLINED'};

        expect(
          FriendRequest.fromJson({...pendingJson, 'id': '1', 'senderId': '2', 'receiverId': '3', 'createdAt': '2024-01-15T10:30:00Z', 'updatedAt': '2024-01-15T10:30:00Z'}).status,
          FriendRequestStatus.pending,
        );
        expect(
          FriendRequest.fromJson({...acceptedJson, 'id': '1', 'senderId': '2', 'receiverId': '3', 'createdAt': '2024-01-15T10:30:00Z', 'updatedAt': '2024-01-15T10:30:00Z'}).status,
          FriendRequestStatus.accepted,
        );
        expect(
          FriendRequest.fromJson({...declinedJson, 'id': '1', 'senderId': '2', 'receiverId': '3', 'createdAt': '2024-01-15T10:30:00Z', 'updatedAt': '2024-01-15T10:30:00Z'}).status,
          FriendRequestStatus.declined,
        );
      });
    });

    group('UserFollow', () {
      test('fromJson creates UserFollow from JSON', () {
        final json = {
          'id': 'follow-123',
          'followerId': 'user-456',
          'followedId': 'user-789',
          'createdAt': '2024-01-15T10:30:00Z',
        };

        final userFollow = UserFollow.fromJson(json);

        expect(userFollow.id, 'follow-123');
        expect(userFollow.followerId, 'user-456');
        expect(userFollow.followedId, 'user-789');
        expect(userFollow.createdAt.year, 2024);
      });

      test('toJson converts UserFollow correctly', () {
        final userFollow = UserFollow(
          id: 'follow-123',
          followerId: 'user-456',
          followedId: 'user-789',
          createdAt: DateTime.parse('2024-01-15T10:30:00Z'),
        );

        final json = userFollow.toJson();

        expect(json['id'], 'follow-123');
        expect(json['followerId'], 'user-456');
        expect(json['followedId'], 'user-789');
        expect(json['createdAt'], '2024-01-15T10:30:00.000Z');
      });
    });

    group('Friendship', () {
      test('fromJson creates Friendship from JSON', () {
        final json = {
          'userId': 'user-123',
          'friendId': 'user-456',
        };

        final friendship = Friendship.fromJson(json);

        expect(friendship.userId, 'user-123');
        expect(friendship.friendId, 'user-456');
      });

      test('toJson converts Friendship correctly', () {
        final friendship = Friendship(
          userId: 'user-123',
          friendId: 'user-456',
        );

        final json = friendship.toJson();

        expect(json['userId'], 'user-123');
        expect(json['friendId'], 'user-456');
      });
    });

    group('FriendRequestRequest', () {
      test('toJson converts FriendRequestRequest correctly', () {
        final request = FriendRequestRequest(receiverId: 'user-123');

        final json = request.toJson();

        expect(json['receiverId'], 'user-123');
      });
    });

    group('UserFollowRequest', () {
      test('toJson converts UserFollowRequest correctly', () {
        final request = UserFollowRequest(followedId: 'user-123');

        final json = request.toJson();

        expect(json['followedId'], 'user-123');
      });
    });

    group('FriendRequestStatus', () {
      test('fromString converts status strings correctly', () {
        expect(
          FriendRequestStatus.fromString('PENDING'),
          FriendRequestStatus.pending,
        );
        expect(
          FriendRequestStatus.fromString('ACCEPTED'),
          FriendRequestStatus.accepted,
        );
        expect(
          FriendRequestStatus.fromString('DECLINED'),
          FriendRequestStatus.declined,
        );
      });

      test('toJson converts status to string correctly', () {
        expect(FriendRequestStatus.pending.toJson(), 'PENDING');
        expect(FriendRequestStatus.accepted.toJson(), 'ACCEPTED');
        expect(FriendRequestStatus.declined.toJson(), 'DECLINED');
      });

      test('handles lowercase status strings', () {
        expect(
          FriendRequestStatus.fromString('pending'),
          FriendRequestStatus.pending,
        );
        expect(
          FriendRequestStatus.fromString('accepted'),
          FriendRequestStatus.accepted,
        );
      });

      test('defaults to pending for unknown status', () {
        expect(
          FriendRequestStatus.fromString('UNKNOWN'),
          FriendRequestStatus.pending,
        );
      });
    });
  });
}
