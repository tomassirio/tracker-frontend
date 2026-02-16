import '../../../core/constants/api_endpoints.dart';
import '../../models/comment_models.dart';
import '../api_client.dart';

/// Comment command client for write operations (Port 8081)
class CommentCommandClient {
  final ApiClient _apiClient;

  CommentCommandClient({ApiClient? apiClient})
      : _apiClient =
            apiClient ?? ApiClient(baseUrl: ApiEndpoints.commandBaseUrl);

  /// Create a new comment (top-level or reply)
  /// Requires authentication (USER, ADMIN)
  /// Returns the comment ID immediately. Full data will be delivered via WebSocket.
  Future<String> createComment(
    String tripId,
    CreateCommentRequest request,
  ) async {
    final response = await _apiClient.post(
      ApiEndpoints.tripComments(tripId),
      body: request.toJson(),
      requireAuth: true,
    );
    return _apiClient.handleAcceptedResponse(response);
  }

  /// Add a reaction to a comment
  /// Requires authentication (USER, ADMIN)
  /// Returns the comment ID immediately. Full data will be delivered via WebSocket.
  Future<String> addReaction(
      String commentId, AddReactionRequest request) async {
    final response = await _apiClient.post(
      ApiEndpoints.commentReactions(commentId),
      body: request.toJson(),
      requireAuth: true,
    );
    return _apiClient.handleAcceptedResponse(response);
  }

  /// Remove a reaction from a comment
  /// Requires authentication (USER, ADMIN)
  /// Returns the comment ID immediately. Full data will be delivered via WebSocket.
  Future<String> removeReaction(String commentId) async {
    final response = await _apiClient.delete(
      ApiEndpoints.commentReactions(commentId),
      requireAuth: true,
    );
    return _apiClient.handleAcceptedResponse(response);
  }
}
