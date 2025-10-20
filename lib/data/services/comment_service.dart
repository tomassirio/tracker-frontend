import '../models/comment_models.dart';
import '../../core/constants/api_endpoints.dart';
import 'api_client.dart';

/// Service for comment and reaction operations
class CommentService {
  final ApiClient _apiClient;

  CommentService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Get comments for a trip
  Future<List<Comment>> getTripComments(String tripId) async {
    final response = await _apiClient.get(
      ApiEndpoints.tripComments(tripId),
      requireAuth: true,
    );

    return _apiClient.handleListResponse(
      response,
      (json) => Comment.fromJson(json),
    );
  }

  /// Add a comment to a trip
  Future<Comment> addComment(
    String tripId,
    CreateCommentRequest request,
  ) async {
    final response = await _apiClient.post(
      ApiEndpoints.tripComments(tripId),
      body: request.toJson(),
      requireAuth: true,
    );

    return _apiClient.handleResponse(
      response,
      (json) => Comment.fromJson(json),
    );
  }

  /// Reply to a comment
  Future<Comment> replyToComment(
    String tripId,
    String commentId,
    CreateCommentResponseRequest request,
  ) async {
    final response = await _apiClient.post(
      ApiEndpoints.commentResponses(tripId, commentId),
      body: request.toJson(),
      requireAuth: true,
    );

    return _apiClient.handleResponse(
      response,
      (json) => Comment.fromJson(json),
    );
  }

  /// Get reactions for a comment
  Future<List<Reaction>> getCommentReactions(
    String tripId,
    String commentId,
  ) async {
    final response = await _apiClient.get(
      ApiEndpoints.commentReactions(tripId, commentId),
      requireAuth: true,
    );

    return _apiClient.handleListResponse(
      response,
      (json) => Reaction.fromJson(json),
    );
  }

  /// Add a reaction to a comment
  Future<Reaction> addReaction(
    String tripId,
    String commentId,
    AddReactionRequest request,
  ) async {
    final response = await _apiClient.post(
      ApiEndpoints.commentReactions(tripId, commentId),
      body: request.toJson(),
      requireAuth: true,
    );

    return _apiClient.handleResponse(
      response,
      (json) => Reaction.fromJson(json),
    );
  }

  /// Remove a reaction from a comment
  Future<void> removeReaction(String tripId, String commentId) async {
    final response = await _apiClient.delete(
      ApiEndpoints.commentReactions(tripId, commentId),
      requireAuth: true,
    );

    _apiClient.handleNoContentResponse(response);
  }
}
