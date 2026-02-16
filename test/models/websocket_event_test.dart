import 'package:flutter_test/flutter_test.dart';
import 'package:tracker_frontend/data/models/websocket/websocket_event.dart';

void main() {
  group('WebSocketEvent - Friend & Follower Events', () {
    group('UserFollowedEvent', () {
      test('fromJson creates UserFollowedEvent from JSON', () {
        final json = {
          'type': 'USER_FOLLOWED',
          'payload': {
            'followerId': 'user-123',
            'followedId': 'user-456',
          },
          'timestamp': '2024-01-15T10:30:00Z',
        };

        final event = UserFollowedEvent.fromJson(json);

        expect(event.type, WebSocketEventType.userFollowed);
        expect(event.followerId, 'user-123');
        expect(event.followedId, 'user-456');
        expect(event.timestamp.year, 2024);
      });

      test('handles missing timestamp', () {
        final json = {
          'payload': {
            'followerId': 'user-123',
            'followedId': 'user-456',
          },
        };

        final event = UserFollowedEvent.fromJson(json);

        expect(event.followerId, 'user-123');
        expect(event.followedId, 'user-456');
      });
    });

    group('UserUnfollowedEvent', () {
      test('fromJson creates UserUnfollowedEvent from JSON', () {
        final json = {
          'type': 'USER_UNFOLLOWED',
          'payload': {
            'followerId': 'user-123',
            'followedId': 'user-456',
          },
          'timestamp': '2024-01-15T10:30:00Z',
        };

        final event = UserUnfollowedEvent.fromJson(json);

        expect(event.type, WebSocketEventType.userUnfollowed);
        expect(event.followerId, 'user-123');
        expect(event.followedId, 'user-456');
      });
    });

    group('FriendRequestSentEvent', () {
      test('fromJson creates FriendRequestSentEvent from JSON', () {
        final json = {
          'type': 'FRIEND_REQUEST_SENT',
          'payload': {
            'requestId': 'request-123',
            'senderId': 'user-456',
            'receiverId': 'user-789',
          },
          'timestamp': '2024-01-15T10:30:00Z',
        };

        final event = FriendRequestSentEvent.fromJson(json);

        expect(event.type, WebSocketEventType.friendRequestSent);
        expect(event.requestId, 'request-123');
        expect(event.senderId, 'user-456');
        expect(event.receiverId, 'user-789');
      });

      test('handles id field as fallback for requestId', () {
        final json = {
          'payload': {
            'id': 'request-123',
            'senderId': 'user-456',
            'receiverId': 'user-789',
          },
        };

        final event = FriendRequestSentEvent.fromJson(json);

        expect(event.requestId, 'request-123');
      });
    });

    group('FriendRequestAcceptedEvent', () {
      test('fromJson creates FriendRequestAcceptedEvent from JSON', () {
        final json = {
          'type': 'FRIEND_REQUEST_ACCEPTED',
          'payload': {
            'requestId': 'request-123',
            'senderId': 'user-456',
            'receiverId': 'user-789',
          },
          'timestamp': '2024-01-15T10:30:00Z',
        };

        final event = FriendRequestAcceptedEvent.fromJson(json);

        expect(event.type, WebSocketEventType.friendRequestAccepted);
        expect(event.requestId, 'request-123');
        expect(event.senderId, 'user-456');
        expect(event.receiverId, 'user-789');
      });
    });

    group('FriendRequestDeclinedEvent', () {
      test('fromJson creates FriendRequestDeclinedEvent from JSON', () {
        final json = {
          'type': 'FRIEND_REQUEST_DECLINED',
          'payload': {
            'requestId': 'request-123',
            'senderId': 'user-456',
            'receiverId': 'user-789',
          },
          'timestamp': '2024-01-15T10:30:00Z',
        };

        final event = FriendRequestDeclinedEvent.fromJson(json);

        expect(event.type, WebSocketEventType.friendRequestDeclined);
        expect(event.requestId, 'request-123');
        expect(event.senderId, 'user-456');
        expect(event.receiverId, 'user-789');
      });
    });

    group('WebSocketEvent.parseEventType', () {
      test('parses friend and follower event types correctly', () {
        expect(
          WebSocketEvent.parseEventType('USER_FOLLOWED'),
          WebSocketEventType.userFollowed,
        );
        expect(
          WebSocketEvent.parseEventType('USER_UNFOLLOWED'),
          WebSocketEventType.userUnfollowed,
        );
        expect(
          WebSocketEvent.parseEventType('FRIEND_REQUEST_SENT'),
          WebSocketEventType.friendRequestSent,
        );
        expect(
          WebSocketEvent.parseEventType('FRIEND_REQUEST_ACCEPTED'),
          WebSocketEventType.friendRequestAccepted,
        );
        expect(
          WebSocketEvent.parseEventType('FRIEND_REQUEST_DECLINED'),
          WebSocketEventType.friendRequestDeclined,
        );
        expect(
          WebSocketEvent.parseEventType('FRIENDSHIP_CREATED'),
          WebSocketEventType.friendshipCreated,
        );
        expect(
          WebSocketEvent.parseEventType('FRIENDSHIP_REMOVED'),
          WebSocketEventType.friendshipRemoved,
        );
      });

      test('handles lowercase event types', () {
        expect(
          WebSocketEvent.parseEventType('user_followed'),
          WebSocketEventType.userFollowed,
        );
      });

      test('returns unknown for invalid event types', () {
        expect(
          WebSocketEvent.parseEventType('INVALID_EVENT'),
          WebSocketEventType.unknown,
        );
      });
    });
  });
}
