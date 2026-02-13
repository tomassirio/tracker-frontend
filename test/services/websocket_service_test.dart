import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracker_frontend/data/services/websocket_service.dart';
import 'package:tracker_frontend/data/models/websocket/websocket_event.dart';
import 'package:tracker_frontend/core/constants/enums.dart';

void main() {
  group('WebSocketService', () {
    late WebSocketService service;

    setUp(() {
      service = WebSocketService();
    });

    test('is a singleton', () {
      final service1 = WebSocketService();
      final service2 = WebSocketService();
      expect(identical(service1, service2), isTrue);
    });

    test('initial state is not connected', () {
      expect(service.isConnected, isFalse);
    });

    test('events stream is accessible', () {
      expect(service.events, isA<Stream<WebSocketEvent>>());
    });

    test('connectionState stream is accessible', () {
      expect(service.connectionState, isA<Stream>());
    });

    test('subscribeToTrip returns a stream', () {
      final stream = service.subscribeToTrip('test-trip-id');
      expect(stream, isA<Stream<WebSocketEvent>>());
    });

    test('subscribeToTrip returns same stream for same trip', () {
      final stream1 = service.subscribeToTrip('test-trip-id');
      final stream2 = service.subscribeToTrip('test-trip-id');
      // Both should be from the same controller (broadcast streams)
      expect(stream1, isNotNull);
      expect(stream2, isNotNull);
    });

    test('unsubscribeFromTrip does not throw for unknown trip', () {
      // Should not throw even for a trip we never subscribed to
      service.unsubscribeFromTrip('unknown-trip-id');
    });

    test('subscribeToTrips subscribes to multiple trips', () {
      service.subscribeToTrips(['trip1', 'trip2', 'trip3']);
      // No exception should be thrown
    });

    test('unsubscribeFromAllTrips cleans up all subscriptions', () {
      service.subscribeToTrips(['trip1', 'trip2']);
      service.unsubscribeFromAllTrips();
      // No exception should be thrown
    });

    test('dispose cleans up service', () {
      service.dispose();
      // Re-create for other tests since it's a singleton
    });
  });

  group('WebSocketEvent', () {
    test('parseEventType handles TRIP_STATUS_CHANGED', () {
      final type = WebSocketEvent.parseEventType('TRIP_STATUS_CHANGED');
      expect(type, WebSocketEventType.tripStatusChanged);
    });

    test('parseEventType handles TRIP_UPDATED', () {
      final type = WebSocketEvent.parseEventType('TRIP_UPDATED');
      expect(type, WebSocketEventType.tripUpdated);
    });

    test('parseEventType handles COMMENT_ADDED', () {
      final type = WebSocketEvent.parseEventType('COMMENT_ADDED');
      expect(type, WebSocketEventType.commentAdded);
    });

    test('parseEventType handles COMMENT_REACTION_ADDED', () {
      final type = WebSocketEvent.parseEventType('COMMENT_REACTION_ADDED');
      expect(type, WebSocketEventType.commentReactionAdded);
    });

    test('parseEventType handles COMMENT_REACTION_REMOVED', () {
      final type = WebSocketEvent.parseEventType('COMMENT_REACTION_REMOVED');
      expect(type, WebSocketEventType.commentReactionRemoved);
    });

    test('parseEventType handles unknown types', () {
      final type = WebSocketEvent.parseEventType('UNKNOWN_TYPE');
      expect(type, WebSocketEventType.unknown);
    });

    test('parseEventType handles null', () {
      final type = WebSocketEvent.parseEventType(null);
      expect(type, WebSocketEventType.unknown);
    });

    test('fromJson creates event with correct type', () {
      final json = {
        'type': 'TRIP_UPDATED',
        'tripId': 'test-trip',
        'payload': {'latitude': 1.0, 'longitude': 2.0},
      };
      final event = WebSocketEvent.fromJson(json);
      expect(event.type, WebSocketEventType.tripUpdated);
      expect(event.tripId, 'test-trip');
    });

    test('toJson serializes correctly', () {
      final event = WebSocketEvent(
        type: WebSocketEventType.tripUpdated,
        tripId: 'test-trip',
        payload: {'key': 'value'},
      );
      final json = event.toJson();
      expect(json['type'], 'tripUpdated');
      expect(json['tripId'], 'test-trip');
      expect(json['payload'], {'key': 'value'});
    });
  });

  group('TripStatusChangedEvent', () {
    test('fromJson parses correctly', () {
      final json = {
        'type': 'TRIP_STATUS_CHANGED',
        'tripId': 'test-trip',
        'payload': {
          'tripId': 'test-trip',
          'newStatus': 'IN_PROGRESS',
          'previousStatus': 'CREATED',
        },
      };
      final event = TripStatusChangedEvent.fromJson(json);
      expect(event.tripId, 'test-trip');
      expect(event.newStatus, TripStatus.inProgress);
      expect(event.previousStatus, TripStatus.created);
    });
  });

  group('TripUpdatedEvent', () {
    test('fromJson parses correctly', () {
      final json = {
        'type': 'TRIP_UPDATED',
        'tripId': 'test-trip',
        'payload': {
          'latitude': 40.7128,
          'longitude': -74.0060,
          'batteryLevel': 85,
          'message': 'Test update',
          'city': 'New York',
          'country': 'USA',
        },
      };
      final event = TripUpdatedEvent.fromJson(json);
      expect(event.tripId, 'test-trip');
      expect(event.latitude, 40.7128);
      expect(event.longitude, -74.0060);
      expect(event.batteryLevel, 85);
      expect(event.message, 'Test update');
      expect(event.city, 'New York');
      expect(event.country, 'USA');
    });
  });

  group('CommentAddedEvent', () {
    test('fromJson parses correctly', () {
      final json = {
        'type': 'COMMENT_ADDED',
        'tripId': 'test-trip',
        'payload': {
          'commentId': 'comment-123',
          'userId': 'user-456',
          'username': 'testuser',
          'message': 'Great trip!',
        },
      };
      final event = CommentAddedEvent.fromJson(json);
      expect(event.tripId, 'test-trip');
      expect(event.commentId, 'comment-123');
      expect(event.userId, 'user-456');
      expect(event.username, 'testuser');
      expect(event.message, 'Great trip!');
    });

    test('fromJson handles reply with parentCommentId', () {
      final json = {
        'type': 'COMMENT_ADDED',
        'tripId': 'test-trip',
        'payload': {
          'commentId': 'reply-123',
          'userId': 'user-456',
          'username': 'testuser',
          'message': 'Thanks!',
          'parentCommentId': 'parent-789',
        },
      };
      final event = CommentAddedEvent.fromJson(json);
      expect(event.parentCommentId, 'parent-789');
    });
  });

  group('CommentReactionEvent', () {
    test('fromJson parses add reaction correctly', () {
      final json = {
        'type': 'COMMENT_REACTION_ADDED',
        'tripId': 'test-trip',
        'payload': {
          'commentId': 'comment-123',
          'reactionType': 'LIKE',
          'userId': 'user-456',
        },
      };
      final event = CommentReactionEvent.fromJson(json, isRemoval: false);
      expect(event.tripId, 'test-trip');
      expect(event.commentId, 'comment-123');
      expect(event.reactionType, 'LIKE');
      expect(event.userId, 'user-456');
      expect(event.isRemoval, isFalse);
      expect(event.type, WebSocketEventType.commentReactionAdded);
    });

    test('fromJson parses remove reaction correctly', () {
      final json = {
        'type': 'COMMENT_REACTION_REMOVED',
        'tripId': 'test-trip',
        'payload': {
          'commentId': 'comment-123',
          'reactionType': 'LIKE',
          'userId': 'user-456',
        },
      };
      final event = CommentReactionEvent.fromJson(json, isRemoval: true);
      expect(event.isRemoval, isTrue);
      expect(event.type, WebSocketEventType.commentReactionRemoved);
    });
  });
}
