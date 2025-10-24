import '../../../core/constants/api_endpoints.dart';
import '../../models/comment_models.dart';
import '../api_client.dart';

/// Comment query client for read operations (Port 8082)
class CommentQueryClient {
  final ApiClient _apiClient;

  CommentQueryClient({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient(baseUrl: ApiEndpoints.queryBaseUrl);

  /// Get comment by ID
  /// Requires authentication (USER, ADMIN)
  Future<Comment> getCommentById(String commentId) async {
    final response = await _apiClient.get(
      '/comments/$commentId',
      requireAuth: true,
    );
    return _apiClient.handleResponse(response, Comment.fromJson);
  }

  /// Get all comments for a trip (includes top-level comments with replies)
  /// Requires authentication (USER, ADMIN)
  Future<List<Comment>> getTripComments(String tripId) async {
    final response = await _apiClient.get(
      ApiEndpoints.tripComments(tripId),
      requireAuth: true,
    );
    return _apiClient.handleListResponse(response, Comment.fromJson);
  }
}
