import 'package:tracker_frontend/data/models/comment_models.dart';
import 'package:tracker_frontend/data/models/trip_models.dart';
import 'package:tracker_frontend/data/services/comment_service.dart';
import 'package:tracker_frontend/data/services/trip_service.dart';
import 'package:tracker_frontend/data/services/auth_service.dart';
import 'package:tracker_frontend/core/constants/enums.dart';

/// Repository for managing trip detail data and operations
class TripDetailRepository {
  final TripService _tripService;
  final CommentService _commentService;
  final AuthService _authService;

  TripDetailRepository({
    TripService? tripService,
    CommentService? commentService,
    AuthService? authService,
  }) : _tripService = tripService ?? TripService(),
       _commentService = commentService ?? CommentService(),
       _authService = authService ?? AuthService();

  /// Loads top-level comments for a trip
  Future<List<Comment>> loadComments(Trip trip) async {
    final allComments = trip.comments ?? [];
    return allComments.where((c) => c.parentCommentId == null).toList();
  }

  /// Loads replies for a specific comment
  Future<List<Comment>> loadReplies(
    List<Comment> comments,
    String commentId,
  ) async {
    final comment = comments.firstWhere((c) => c.id == commentId);
    return comment.replies ?? [];
  }

  /// Loads reactions for a comment from the comment object itself
  /// Note: Reactions are stored as a `Map<String, int>` in the comment model (reaction type -> count)
  /// This method returns an empty list as reactions are already embedded in the comment
  Future<List<Reaction>> loadReactions(Comment comment) async {
    // Reactions are already part of the comment object as a map
    // Return empty list since the UI should use comment.reactions map directly
    return [];
  }

  /// Adds a new top-level comment
  Future<Comment> addComment(String tripId, String message) async {
    return await _commentService.addComment(
      tripId,
      CreateCommentRequest(message: message),
    );
  }

  /// Adds a reply to a comment
  /// Uses parentCommentId in the request body to create a reply
  Future<Comment> addReply(
    String tripId,
    String parentCommentId,
    String message,
  ) async {
    return await _commentService.addComment(
      tripId,
      CreateCommentRequest(message: message, parentCommentId: parentCommentId),
    );
  }

  /// Adds a reaction to a comment
  Future<void> addReaction(String commentId, ReactionType reactionType) async {
    final request = AddReactionRequest(reactionType: reactionType);
    await _commentService.addReaction(commentId, request);
  }

  /// Removes a reaction from a comment
  Future<void> removeReaction(String commentId) async {
    await _commentService.removeReaction(commentId);
  }

  /// Changes the status of a trip
  Future<Trip> changeTripStatus(String tripId, TripStatus newStatus) async {
    final request = ChangeStatusRequest(status: newStatus);
    return await _tripService.changeStatus(tripId, request);
  }

  /// Checks if user is logged in
  Future<bool> isLoggedIn() async {
    return await _authService.isLoggedIn();
  }
}
