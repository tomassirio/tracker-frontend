import 'package:tracker_frontend/data/models/comment_models.dart';
import 'package:tracker_frontend/data/models/trip_models.dart';
import 'package:tracker_frontend/data/services/comment_service.dart';
import 'package:tracker_frontend/data/services/trip_service.dart';
import 'package:tracker_frontend/core/constants/enums.dart';

/// Repository for managing trip detail data and operations
class TripDetailRepository {
  final TripService _tripService;
  final CommentService _commentService;

  TripDetailRepository({
    TripService? tripService,
    CommentService? commentService,
  })  : _tripService = tripService ?? TripService(),
        _commentService = commentService ?? CommentService();

  /// Loads top-level comments for a trip
  Future<List<Comment>> loadComments(Trip trip) async {
    final allComments = trip.comments ?? [];
    return allComments.where((c) => c.parentCommentId == null).toList();
  }

  /// Loads replies for a specific comment
  Future<List<Comment>> loadReplies(List<Comment> comments, String commentId) async {
    final comment = comments.firstWhere((c) => c.id == commentId);
    return comment.replies ?? [];
  }

  /// Loads reactions for a comment
  Future<List<Reaction>> loadReactions(String tripId, String commentId) async {
    return await _commentService.getCommentReactions(tripId, commentId);
  }

  /// Adds a new top-level comment
  Future<Comment> addComment(String tripId, String message) async {
    return await _commentService.addComment(
      tripId,
      CreateCommentRequest(message: message),
    );
  }

  /// Adds a reply to a comment
  Future<Comment> addReply(String tripId, String commentId, String message) async {
    return await _commentService.replyToComment(
      tripId,
      commentId,
      CreateCommentResponseRequest(message: message),
    );
  }

  /// Adds a reaction to a comment
  Future<void> addReaction(String tripId, String commentId, ReactionType type) async {
    await _commentService.addReaction(
      tripId,
      commentId,
      AddReactionRequest(type: type),
    );
  }

  /// Changes the status of a trip
  Future<Trip> changeTripStatus(String tripId, TripStatus newStatus) async {
    final request = ChangeStatusRequest(status: newStatus);
    return await _tripService.changeStatus(tripId, request);
  }
}

