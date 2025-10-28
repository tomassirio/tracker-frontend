import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tracker_frontend/data/models/comment_models.dart';
import 'package:tracker_frontend/data/models/trip_models.dart';
import 'package:tracker_frontend/data/repositories/trip_detail_repository.dart';
import 'package:tracker_frontend/data/services/comment_service.dart';
import 'package:tracker_frontend/data/services/trip_service.dart';
import 'package:tracker_frontend/data/services/auth_service.dart';

import 'trip_detail_repository_test.mocks.dart';

@GenerateMocks([CommentService, TripService, AuthService])
void main() {
  group('TripDetailRepository', () {
    late MockCommentService mockCommentService;
    late MockTripService mockTripService;
    late MockAuthService mockAuthService;
    late TripDetailRepository repository;

    setUp(() {
      mockCommentService = MockCommentService();
      mockTripService = MockTripService();
      mockAuthService = MockAuthService();
      repository = TripDetailRepository(
        commentService: mockCommentService,
        tripService: mockTripService,
        authService: mockAuthService,
      );
    });

    group('loadComments', () {
      test('returns only top-level comments from API', () async {
        final topComment1 = createMockComment('comment-1', null);
        final topComment2 = createMockComment('comment-2', null);
        final replyComment = createMockComment('comment-3', 'comment-1');

        when(
          mockCommentService.getCommentsByTripId('trip-1'),
        ).thenAnswer((_) async => [topComment1, topComment2, replyComment]);

        final result = await repository.loadComments('trip-1');

        expect(result.length, 2);
        expect(result[0].id, 'comment-1');
        expect(result[1].id, 'comment-2');
        verify(mockCommentService.getCommentsByTripId('trip-1')).called(1);
      });

      test('returns empty list when no comments', () async {
        when(
          mockCommentService.getCommentsByTripId('trip-1'),
        ).thenAnswer((_) async => []);

        final result = await repository.loadComments('trip-1');

        expect(result, isEmpty);
        verify(mockCommentService.getCommentsByTripId('trip-1')).called(1);
      });

      test('handles API errors gracefully', () async {
        when(
          mockCommentService.getCommentsByTripId('trip-1'),
        ).thenThrow(Exception('API Error'));

        expect(() => repository.loadComments('trip-1'), throwsException);
      });

      test(
        'filters out all replies when all comments have parent IDs',
        () async {
          final reply1 = createMockComment('comment-1', 'parent-1');
          final reply2 = createMockComment('comment-2', 'parent-2');

          when(
            mockCommentService.getCommentsByTripId('trip-1'),
          ).thenAnswer((_) async => [reply1, reply2]);

          final result = await repository.loadComments('trip-1');

          expect(result, isEmpty);
        },
      );
    });

    group('loadReplies', () {
      test('returns replies for a specific comment from API', () async {
        final reply1 = createMockComment('reply-1', 'comment-1');
        final reply2 = createMockComment('reply-2', 'comment-1');

        when(
          mockCommentService.getRepliesByCommentId('comment-1'),
        ).thenAnswer((_) async => [reply1, reply2]);

        final result = await repository.loadReplies('comment-1');

        expect(result.length, 2);
        expect(result[0].id, 'reply-1');
        expect(result[1].id, 'reply-2');
        verify(mockCommentService.getRepliesByCommentId('comment-1')).called(1);
      });

      test('returns empty list when comment has no replies', () async {
        when(
          mockCommentService.getRepliesByCommentId('comment-1'),
        ).thenAnswer((_) async => []);

        final result = await repository.loadReplies('comment-1');

        expect(result, isEmpty);
      });

      test('handles API errors gracefully', () async {
        when(
          mockCommentService.getRepliesByCommentId('comment-1'),
        ).thenThrow(Exception('API Error'));

        expect(() => repository.loadReplies('comment-1'), throwsException);
      });
    });

    group('loadReactions', () {
      test('returns empty list as reactions are embedded in comment', () async {
        final comment = createMockComment('comment-1', null);

        final result = await repository.loadReactions(comment);

        expect(result, isEmpty);
      });
    });

    group('addComment', () {
      test('adds a top-level comment successfully', () async {
        final newComment = createMockComment('new-comment', null);

        when(
          mockCommentService.addComment('trip-1', any),
        ).thenAnswer((_) async => newComment);

        final result = await repository.addComment('trip-1', 'Test message');

        expect(result.id, 'new-comment');
        verify(mockCommentService.addComment('trip-1', any)).called(1);
      });
    });

    group('addReply', () {
      test('adds a reply to a comment successfully', () async {
        final newReply = createMockComment('new-reply', 'parent-1');

        when(
          mockCommentService.addComment('trip-1', any),
        ).thenAnswer((_) async => newReply);

        final result = await repository.addReply(
          'trip-1',
          'parent-1',
          'Reply message',
        );

        expect(result.id, 'new-reply');
        expect(result.parentCommentId, 'parent-1');
      });
    });

    group('loadTripUpdates', () {
      test('fetches trip updates from API', () async {
        final updates = [
          createMockTripLocation(1.0, 2.0),
          createMockTripLocation(3.0, 4.0),
        ];

        when(
          mockTripService.getTripUpdates('trip-1'),
        ).thenAnswer((_) async => updates);

        final result = await repository.loadTripUpdates('trip-1');

        expect(result.length, 2);
        verify(mockTripService.getTripUpdates('trip-1')).called(1);
      });

      test('returns empty list when no updates', () async {
        when(
          mockTripService.getTripUpdates('trip-1'),
        ).thenAnswer((_) async => []);

        final result = await repository.loadTripUpdates('trip-1');

        expect(result, isEmpty);
      });
    });
  });
}

// Helper functions
Comment createMockComment(
  String id,
  String? parentCommentId, {
  List<Comment>? replies,
}) {
  return Comment(
    id: id,
    tripId: 'trip-1',
    userId: 'user-1',
    username: 'testuser',
    message: 'Test message',
    parentCommentId: parentCommentId,
    replies: replies,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}

TripLocation createMockTripLocation(double lat, double lng) {
  return TripLocation(
    id: 'location-${lat.toInt()}-${lng.toInt()}',
    latitude: lat,
    longitude: lng,
    timestamp: DateTime.now(),
  );
}
