import '../models/comment_models.dart';
import '../client/clients.dart';

/// Service for comment and reaction operations
class CommentService {
  final CommentCommandClient _commentCommandClient;

  CommentService({CommentCommandClient? commentCommandClient})
    : _commentCommandClient = commentCommandClient ?? CommentCommandClient();

  /// Add a comment to a trip
  Future<Comment> addComment(
    String tripId,
    CreateCommentRequest request,
  ) async {
    return await _commentCommandClient.createComment(tripId, request);
  }

  /// Add a reaction to a comment
  Future<void> addReaction(String commentId, AddReactionRequest request) async {
    await _commentCommandClient.addReaction(commentId, request);
  }

  /// Remove a reaction from a comment
  Future<void> removeReaction(String commentId) async {
    await _commentCommandClient.removeReaction(commentId);
  }
}
