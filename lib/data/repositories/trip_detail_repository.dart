import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tracker_frontend/data/models/comment_models.dart';
import 'package:tracker_frontend/data/models/trip_models.dart';
import 'package:tracker_frontend/data/services/comment_service.dart';
import 'package:tracker_frontend/data/services/trip_service.dart';
import 'package:tracker_frontend/data/services/auth_service.dart';
import 'package:tracker_frontend/data/client/google_geocoding_api_client.dart';
import 'package:tracker_frontend/core/constants/enums.dart';

/// Repository for managing trip detail data and operations
class TripDetailRepository {
  final TripService _tripService;
  final CommentService _commentService;
  final AuthService _authService;
  final GoogleGeocodingApiClient? _geocodingClient;

  TripDetailRepository({
    TripService? tripService,
    CommentService? commentService,
    AuthService? authService,
    GoogleGeocodingApiClient? geocodingClient,
  })  : _tripService = tripService ?? TripService(),
        _commentService = commentService ?? CommentService(),
        _authService = authService ?? AuthService(),
        _geocodingClient = geocodingClient;

  /// Loads top-level comments for a trip via API
  Future<List<Comment>> loadComments(String tripId) async {
    final allComments = await _commentService.getCommentsByTripId(tripId);
    return allComments.where((c) => c.parentCommentId == null).toList();
  }

  /// Loads replies for a specific comment via API
  Future<List<Comment>> loadReplies(String commentId) async {
    return await _commentService.getRepliesByCommentId(commentId);
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

  /// Gets the current user's username
  Future<String?> getCurrentUsername() async {
    return await _authService.getCurrentUsername();
  }

  /// Gets the current user's ID
  Future<String?> getCurrentUserId() async {
    return await _authService.getCurrentUserId();
  }

  /// Logs out the current user
  Future<void> logout() async {
    await _authService.logout();
  }

  /// Loads trip updates for a specific trip via API
  /// Optionally enriches updates with place information (city, country) via geocoding
  Future<List<TripLocation>> loadTripUpdates(
    String tripId, {
    bool enrichWithPlaces = true,
  }) async {
    final updates = await _tripService.getTripUpdates(tripId);

    // If geocoding client is not available or enrichment is disabled, return updates as-is
    if (_geocodingClient == null || !enrichWithPlaces || updates.isEmpty) {
      return updates;
    }

    // Enrich updates with place information (city, country)
    final enrichedUpdates = <TripLocation>[];

    for (final update in updates) {
      // Skip if already has place info
      if (update.city != null && update.country != null) {
        enrichedUpdates.add(update);
        continue;
      }

      // Reverse geocode to get place info
      try {
        final placeInfo = await _geocodingClient.reverseGeocode(
          LatLng(update.latitude, update.longitude),
        );

        if (placeInfo != null) {
          enrichedUpdates.add(
            update.copyWith(city: placeInfo.city, country: placeInfo.country),
          );
        } else {
          enrichedUpdates.add(update);
        }
      } catch (e) {
        // If geocoding fails, just add the update without place info
        enrichedUpdates.add(update);
      }
    }

    return enrichedUpdates;
  }
}
