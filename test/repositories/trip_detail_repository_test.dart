import 'package:flutter_test/flutter_test.dart';
import 'package:tracker_frontend/core/constants/enums.dart';
import 'package:tracker_frontend/data/models/comment_models.dart';
import 'package:tracker_frontend/data/models/trip_models.dart';
import 'package:tracker_frontend/data/repositories/trip_detail_repository.dart';
import 'package:tracker_frontend/data/services/comment_service.dart';
import 'package:tracker_frontend/data/services/trip_service.dart';

void main() {
  group('TripDetailRepository', () {
    late MockTripService mockTripService;
    late MockCommentService mockCommentService;
    late TripDetailRepository repository;

    setUp(() {
      mockTripService = MockTripService();
      mockCommentService = MockCommentService();
      repository = TripDetailRepository(
        tripService: mockTripService,
        commentService: mockCommentService,
      );
    });

    group('loadComments', () {
      test('returns only top-level comments', () async {
        final topComment1 = createMockComment('comment-1', null);
        final topComment2 = createMockComment('comment-2', null);
        final replyComment = createMockComment('comment-3', 'comment-1');

        final trip = createMockTrip(
          comments: [topComment1, topComment2, replyComment],
        );

        final result = await repository.loadComments(trip);

        expect(result.length, 2);
        expect(result[0].id, 'comment-1');
        expect(result[1].id, 'comment-2');
      });

      test('returns empty list when no comments', () async {
        final trip = createMockTrip(comments: []);

        final result = await repository.loadComments(trip);

        expect(result, isEmpty);
      });

      test('returns empty list when trip has null comments', () async {
        final trip = createMockTrip(comments: null);

        final result = await repository.loadComments(trip);

        expect(result, isEmpty);
      });

      test(
        'filters out all replies when all comments have parent IDs',
        () async {
          final reply1 = createMockComment('comment-1', 'parent-1');
          final reply2 = createMockComment('comment-2', 'parent-2');

          final trip = createMockTrip(comments: [reply1, reply2]);

          final result = await repository.loadComments(trip);

          expect(result, isEmpty);
        },
      );
    });

    group('loadReplies', () {
      test('returns replies for a specific comment', () async {
        final reply1 = createMockComment('reply-1', null);
        final reply2 = createMockComment('reply-2', null);
        final parentComment = createMockComment(
          'comment-1',
          null,
          replies: [reply1, reply2],
        );

        final comments = [parentComment];

        final result = await repository.loadReplies(comments, 'comment-1');

        expect(result.length, 2);
        expect(result[0].id, 'reply-1');
        expect(result[1].id, 'reply-2');
      });

      test('returns empty list when comment has no replies', () async {
        final comment = createMockComment('comment-1', null, replies: []);
        final comments = [comment];

        final result = await repository.loadReplies(comments, 'comment-1');

        expect(result, isEmpty);
      });

      test('returns empty list when comment has null replies', () async {
        final comment = createMockComment('comment-1', null);
        final comments = [comment];

        final result = await repository.loadReplies(comments, 'comment-1');

        expect(result, isEmpty);
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
        mockCommentService.mockComment = createMockComment('comment-123', null);

        final result = await repository.addComment('trip-1', 'Test message');

        expect(result.id, 'comment-123');
        expect(mockCommentService.addCommentCalled, true);
        expect(mockCommentService.lastTripId, 'trip-1');
        expect(mockCommentService.lastRequest?.message, 'Test message');
        expect(mockCommentService.lastRequest?.parentCommentId, null);
      });

      test('passes through service errors when adding comment', () async {
        mockCommentService.shouldThrowError = true;

        expect(
          () => repository.addComment('trip-1', 'Test message'),
          throwsException,
        );
      });
    });

    group('addReply', () {
      test('adds a reply to a comment successfully', () async {
        mockCommentService.mockComment = createMockComment(
          'reply-123',
          'parent-1',
        );

        final result = await repository.addReply(
          'trip-1',
          'parent-1',
          'Reply message',
        );

        expect(result.id, 'reply-123');
        expect(result.parentCommentId, 'parent-1');
        expect(mockCommentService.addCommentCalled, true);
        expect(mockCommentService.lastTripId, 'trip-1');
        expect(mockCommentService.lastRequest?.message, 'Reply message');
        expect(mockCommentService.lastRequest?.parentCommentId, 'parent-1');
      });

      test('passes through service errors when adding reply', () async {
        mockCommentService.shouldThrowError = true;

        expect(
          () => repository.addReply('trip-1', 'parent-1', 'Reply message'),
          throwsException,
        );
      });
    });

    group('addReaction', () {
      test('adds reaction successfully', () async {
        await repository.addReaction('comment-1', ReactionType.heart);

        expect(mockCommentService.addReactionCalled, true);
        expect(mockCommentService.lastCommentId, 'comment-1');
        expect(
          mockCommentService.lastReactionRequest?.reactionType,
          ReactionType.heart,
        );
      });

      test('adds different reaction types', () async {
        await repository.addReaction('comment-1', ReactionType.laugh);

        expect(mockCommentService.addReactionCalled, true);
        expect(
          mockCommentService.lastReactionRequest?.reactionType,
          ReactionType.laugh,
        );
      });

      test('passes through service errors when adding reaction', () async {
        mockCommentService.shouldThrowReactionError = true;

        expect(
          () => repository.addReaction('comment-1', ReactionType.anger),
          throwsException,
        );
      });
    });

    group('removeReaction', () {
      test('removes reaction successfully', () async {
        await repository.removeReaction('comment-1');

        expect(mockCommentService.removeReactionCalled, true);
        expect(mockCommentService.lastCommentIdForRemove, 'comment-1');
      });

      test('passes through service errors when removing reaction', () async {
        mockCommentService.shouldThrowRemoveReactionError = true;

        expect(() => repository.removeReaction('comment-1'), throwsException);
      });
    });

    group('changeTripStatus', () {
      test('changes trip status to created', () async {
        mockTripService.mockTrip = createMockTrip(status: TripStatus.created);

        final result = await repository.changeTripStatus(
          'trip-1',
          TripStatus.created,
        );

        expect(result.status, TripStatus.created);
        expect(mockTripService.changeStatusCalled, true);
        expect(mockTripService.lastTripId, 'trip-1');
        expect(mockTripService.lastStatusRequest?.status, TripStatus.created);
      });

      test('changes trip status to paused', () async {
        mockTripService.mockTrip = createMockTrip(status: TripStatus.paused);

        final result = await repository.changeTripStatus(
          'trip-1',
          TripStatus.paused,
        );

        expect(result.status, TripStatus.paused);
        expect(mockTripService.lastStatusRequest?.status, TripStatus.paused);
      });

      test('changes trip status to finished', () async {
        mockTripService.mockTrip = createMockTrip(status: TripStatus.finished);

        final result = await repository.changeTripStatus(
          'trip-1',
          TripStatus.finished,
        );

        expect(result.status, TripStatus.finished);
        expect(mockTripService.lastStatusRequest?.status, TripStatus.finished);
      });

      test('passes through service errors when changing status', () async {
        mockTripService.shouldThrowError = true;

        expect(
          () => repository.changeTripStatus('trip-1', TripStatus.created),
          throwsException,
        );
      });
    });

    group('TripDetailRepository initialization', () {
      test('creates with provided services', () {
        final tripService = MockTripService();
        final commentService = MockCommentService();
        final repo = TripDetailRepository(
          tripService: tripService,
          commentService: commentService,
        );

        expect(repo, isNotNull);
      });

      test('creates with default services when not provided', () {
        final repo = TripDetailRepository();

        expect(repo, isNotNull);
      });
    });

    group('New methods', () {
      test('isLoggedIn method exists', () async {
        expect(repository.isLoggedIn, isA<Function>());
      });

      test('getCurrentUsername method exists', () async {
        expect(repository.getCurrentUsername, isA<Function>());
      });

      test('getCurrentUserId method exists', () async {
        expect(repository.getCurrentUserId, isA<Function>());
      });

      test('logout method exists', () async {
        expect(repository.logout, isA<Function>());
      });

      test('loadTripUpdates method exists', () async {
        expect(repository.loadTripUpdates, isA<Function>());
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

Trip createMockTrip({
  List<Comment>? comments,
  TripStatus status = TripStatus.created,
}) {
  return Trip(
    id: 'trip-1',
    userId: 'user-1',
    name: 'Test Trip',
    username: 'testuser',
    visibility: Visibility.public,
    status: status,
    comments: comments,
    commentsCount: comments?.length ?? 0,
    reactionsCount: 0,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}

// Mock TripService
class MockTripService extends TripService {
  Trip? mockTrip;
  bool changeStatusCalled = false;
  String? lastTripId;
  ChangeStatusRequest? lastStatusRequest;
  bool shouldThrowError = false;

  @override
  Future<Trip> changeStatus(String tripId, ChangeStatusRequest request) async {
    changeStatusCalled = true;
    lastTripId = tripId;
    lastStatusRequest = request;

    if (shouldThrowError) {
      throw Exception('Failed to change trip status');
    }

    return mockTrip ??
        Trip(
          id: tripId,
          userId: 'user-1',
          name: 'Test Trip',
          username: 'testuser',
          visibility: Visibility.public,
          status: request.status,
          commentsCount: 0,
          reactionsCount: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
  }
}

// Mock CommentService
class MockCommentService extends CommentService {
  Comment? mockComment;
  bool addCommentCalled = false;
  bool addReactionCalled = false;
  bool removeReactionCalled = false;
  String? lastTripId;
  String? lastCommentId;
  String? lastCommentIdForRemove;
  CreateCommentRequest? lastRequest;
  AddReactionRequest? lastReactionRequest;
  bool shouldThrowError = false;
  bool shouldThrowReactionError = false;
  bool shouldThrowRemoveReactionError = false;

  @override
  Future<Comment> addComment(
    String tripId,
    CreateCommentRequest request,
  ) async {
    addCommentCalled = true;
    lastTripId = tripId;
    lastRequest = request;

    if (shouldThrowError) {
      throw Exception('Failed to add comment');
    }

    return mockComment ??
        Comment(
          id: 'comment-123',
          tripId: tripId,
          userId: 'user-1',
          username: 'testuser',
          message: request.message,
          parentCommentId: request.parentCommentId,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
  }

  @override
  Future<void> addReaction(String commentId, AddReactionRequest request) async {
    addReactionCalled = true;
    lastCommentId = commentId;
    lastReactionRequest = request;

    if (shouldThrowReactionError) {
      throw Exception('Failed to add reaction');
    }
  }

  @override
  Future<void> removeReaction(String commentId) async {
    removeReactionCalled = true;
    lastCommentIdForRemove = commentId;

    if (shouldThrowRemoveReactionError) {
      throw Exception('Failed to remove reaction');
    }
  }
}
