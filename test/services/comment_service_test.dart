import 'package:flutter_test/flutter_test.dart';
import 'package:tracker_frontend/data/models/comment_models.dart';
import 'package:tracker_frontend/data/services/comment_service.dart';
import 'package:tracker_frontend/data/client/clients.dart';

void main() {
  group('CommentService', () {
    late MockCommentCommandClient mockCommentCommandClient;
    late CommentService commentService;

    setUp(() {
      mockCommentCommandClient = MockCommentCommandClient();
      commentService = CommentService(
        commentCommandClient: mockCommentCommandClient,
      );
    });

    group('addComment', () {
      test('adds top-level comment successfully', () async {
        final request = CreateCommentRequest(message: 'Test comment');
        mockCommentCommandClient.mockCommentId = 'comment-123';

        final result = await commentService.addComment('trip-1', request);

        expect(result, 'comment-123');
        expect(mockCommentCommandClient.createCommentCalled, true);
        expect(mockCommentCommandClient.lastTripId, 'trip-1');
        expect(mockCommentCommandClient.lastRequest?.message, 'Test comment');
      });

      test('adds reply comment successfully', () async {
        final request = CreateCommentRequest(
          message: 'Reply comment',
          parentCommentId: 'parent-1',
        );
        mockCommentCommandClient.mockCommentId = 'comment-456';

        final result = await commentService.addComment('trip-1', request);

        expect(result, 'comment-456');
        expect(
          mockCommentCommandClient.lastRequest?.parentCommentId,
          'parent-1',
        );
      });

      test('passes through errors when adding comment', () async {
        final request = CreateCommentRequest(message: 'Test');
        mockCommentCommandClient.shouldThrowError = true;

        expect(
          () => commentService.addComment('trip-1', request),
          throwsException,
        );
      });
    });

    group('addReaction', () {
      test('adds laugh reaction successfully', () async {
        final request = AddReactionRequest(reactionType: ReactionType.laugh);
        mockCommentCommandClient.mockCommentId = 'comment-1';

        final result = await commentService.addReaction('comment-1', request);

        expect(result, 'comment-1');
        expect(mockCommentCommandClient.addReactionCalled, true);
        expect(mockCommentCommandClient.lastCommentId, 'comment-1');
        expect(
          mockCommentCommandClient.lastReactionRequest?.reactionType,
          ReactionType.laugh,
        );
      });

      test('adds heart reaction successfully', () async {
        final request = AddReactionRequest(reactionType: ReactionType.heart);
        mockCommentCommandClient.mockCommentId = 'comment-2';

        final result = await commentService.addReaction('comment-2', request);

        expect(result, 'comment-2');
        expect(
          mockCommentCommandClient.lastReactionRequest?.reactionType,
          ReactionType.heart,
        );
      });

      test('adds laugh reaction successfully', () async {
        final request = AddReactionRequest(reactionType: ReactionType.laugh);
        mockCommentCommandClient.mockCommentId = 'comment-3';

        final result = await commentService.addReaction('comment-3', request);

        expect(result, 'comment-3');
        expect(
          mockCommentCommandClient.lastReactionRequest?.reactionType,
          ReactionType.laugh,
        );
      });

      test('adds anger reaction successfully', () async {
        final request = AddReactionRequest(reactionType: ReactionType.anger);
        mockCommentCommandClient.mockCommentId = 'comment-4';

        final result = await commentService.addReaction('comment-4', request);

        expect(result, 'comment-4');
        expect(
          mockCommentCommandClient.lastReactionRequest?.reactionType,
          ReactionType.anger,
        );
      });

      test('adds sad reaction successfully', () async {
        final request = AddReactionRequest(reactionType: ReactionType.sad);
        mockCommentCommandClient.mockCommentId = 'comment-5';

        final result = await commentService.addReaction('comment-5', request);

        expect(result, 'comment-5');
        expect(
          mockCommentCommandClient.lastReactionRequest?.reactionType,
          ReactionType.sad,
        );
      });

      test('adds smiley reaction successfully', () async {
        final request = AddReactionRequest(reactionType: ReactionType.smiley);
        mockCommentCommandClient.mockCommentId = 'comment-6';

        final result = await commentService.addReaction('comment-6', request);

        expect(result, 'comment-6');
        expect(
          mockCommentCommandClient.lastReactionRequest?.reactionType,
          ReactionType.smiley,
        );
      });

      test('passes through errors when adding reaction', () async {
        final request = AddReactionRequest(reactionType: ReactionType.smiley);
        mockCommentCommandClient.shouldThrowError = true;

        expect(
          () => commentService.addReaction('comment-1', request),
          throwsException,
        );
      });
    });

    group('removeReaction', () {
      test('removes reaction successfully', () async {
        mockCommentCommandClient.mockCommentId = 'comment-1';

        final result = await commentService.removeReaction('comment-1');

        expect(result, 'comment-1');
        expect(mockCommentCommandClient.removeReactionCalled, true);
        expect(mockCommentCommandClient.lastCommentIdForRemove, 'comment-1');
      });

      test('passes through errors when removing reaction', () async {
        mockCommentCommandClient.shouldThrowError = true;

        expect(
          () => commentService.removeReaction('comment-1'),
          throwsException,
        );
      });
    });

    group('CommentService initialization', () {
      test('creates with provided client', () {
        final client = MockCommentCommandClient();
        final service = CommentService(commentCommandClient: client);

        expect(service, isNotNull);
      });

      test('creates with default client when not provided', () {
        final service = CommentService();

        expect(service, isNotNull);
      });
    });
  });
}

// Helper function
Comment createMockComment(String id, String? parentCommentId) {
  return Comment(
    id: id,
    tripId: 'trip-1',
    userId: 'user-1',
    username: 'testuser',
    message: 'Test message',
    parentCommentId: parentCommentId,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}

// Mock CommentCommandClient
class MockCommentCommandClient extends CommentCommandClient {
  String? mockCommentId;
  bool createCommentCalled = false;
  bool addReactionCalled = false;
  bool removeReactionCalled = false;
  String? lastTripId;
  String? lastCommentId;
  String? lastCommentIdForRemove;
  CreateCommentRequest? lastRequest;
  AddReactionRequest? lastReactionRequest;
  bool shouldThrowError = false;

  @override
  Future<String> createComment(
    String tripId,
    CreateCommentRequest request,
  ) async {
    createCommentCalled = true;
    lastTripId = tripId;
    lastRequest = request;
    if (shouldThrowError) throw Exception('Failed to create comment');
    return mockCommentId!;
  }

  @override
  Future<String> addReaction(
      String commentId, AddReactionRequest request) async {
    addReactionCalled = true;
    lastCommentId = commentId;
    lastReactionRequest = request;
    if (shouldThrowError) throw Exception('Failed to add reaction');
    return mockCommentId!;
  }

  @override
  Future<String> removeReaction(String commentId) async {
    removeReactionCalled = true;
    lastCommentIdForRemove = commentId;
    if (shouldThrowError) throw Exception('Failed to remove reaction');
    return mockCommentId!;
  }
}
