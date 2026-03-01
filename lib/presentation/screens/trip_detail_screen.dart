import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart' hide Visibility;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tracker_frontend/data/models/trip_models.dart';
import 'package:tracker_frontend/data/models/user_models.dart';
import 'package:tracker_frontend/data/models/comment_models.dart';
import 'package:tracker_frontend/data/models/achievement_models.dart';
import 'package:tracker_frontend/data/models/websocket/websocket_event.dart';
import 'package:tracker_frontend/data/repositories/trip_detail_repository.dart';
import 'package:tracker_frontend/data/client/query/promotion_query_client.dart';
import 'package:tracker_frontend/data/client/google_geocoding_api_client.dart';
import 'package:tracker_frontend/data/services/websocket_service.dart';
import 'package:tracker_frontend/data/services/user_service.dart';
import 'package:tracker_frontend/data/services/achievement_service.dart';
import 'package:tracker_frontend/core/constants/api_endpoints.dart';
import 'package:tracker_frontend/core/constants/enums.dart';
import 'package:tracker_frontend/core/services/background_update_manager.dart';
import 'package:tracker_frontend/presentation/helpers/trip_map_helper.dart';
import 'package:tracker_frontend/presentation/helpers/ui_helpers.dart';
import 'package:tracker_frontend/presentation/helpers/dialog_helper.dart';
import 'package:tracker_frontend/presentation/helpers/auth_navigation_helper.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tracker_frontend/presentation/widgets/trip_detail/reaction_picker.dart';
import 'package:tracker_frontend/presentation/widgets/trip_detail/trip_map_view.dart';
import 'package:tracker_frontend/presentation/widgets/trip_detail/comments_section.dart';
import 'package:tracker_frontend/presentation/widgets/common/wanderer_app_bar.dart';
import 'package:tracker_frontend/presentation/widgets/common/app_sidebar.dart';
import 'package:tracker_frontend/presentation/strategies/trip_detail_layout_strategy.dart';
import 'auth_screen.dart';
import 'home_screen.dart';

/// Trip detail screen showing trip info, map, and comments
class TripDetailScreen extends StatefulWidget {
  final Trip trip;

  const TripDetailScreen({super.key, required this.trip});

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  late final TripDetailRepository _repository;
  final UserService _userService = UserService();
  final PromotionQueryClient _promotionQueryClient = PromotionQueryClient();
  final AchievementService _achievementService = AchievementService();
  final WebSocketService _webSocketService = WebSocketService();
  final TextEditingController _searchController = TextEditingController();
  GoogleMapController? _mapController;
  StreamSubscription<WebSocketEvent>? _wsSubscription;
  late Trip _trip;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  List<Comment> _comments = [];
  final Map<String, List<Comment>> _replies = {};
  final Map<String, bool> _expandedComments = {};

  List<TripLocation> _tripUpdates = [];
  bool _isLoadingUpdates = false;

  bool _isLoadingComments = false;
  bool _isAddingComment = false;
  bool _isLoggedIn = false;
  bool _isAdmin = false;
  bool _isChangingStatus = false;
  bool _isChangingSettings = false;
  String? _replyingToCommentId;
  CommentSortOption _sortOption = CommentSortOption.latest;
  final int _selectedSidebarIndex = -1; // Trip detail is not a main nav item
  String? _username;
  String? _userId;
  String? _displayName;
  String? _avatarUrl;

  // Track social interactions
  bool _isFollowingTripOwner = false;
  bool _hasSentFriendRequest = false;
  bool _isAlreadyFriends = false;
  String? _sentFriendRequestId; // Store the request ID for cancellation

  // Promotion state
  bool _isPromoted = false;
  String? _donationLink;

  // Trip achievements
  List<UserAchievement> _tripAchievements = [];

  // Collapsible panel states
  bool _isTimelineCollapsed = false;
  bool _isCommentsCollapsed = false;
  bool _isTripInfoCollapsed = false;
  bool _isTripUpdateCollapsed = true;
  bool _isSendingUpdate = false;
  bool _hasInitializedPanelStates = false;

  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  /// Check if we're on Android (the only platform supporting background updates)
  bool get _isAndroid => !kIsWeb && Platform.isAndroid;

  /// Check if trip update panel should be shown
  /// Only on Android, for trip owner, when trip is in progress
  bool get _showTripUpdatePanel =>
      _isAndroid &&
      _userId != null &&
      _trip.userId == _userId &&
      _trip.status == TripStatus.inProgress;

  @override
  void initState() {
    super.initState();

    // Initialize repository with geocoding client for place enrichment
    final apiKey = ApiEndpoints.googleMapsApiKey;
    final geocodingClient =
        apiKey.isNotEmpty ? GoogleGeocodingApiClient(apiKey) : null;
    _repository = TripDetailRepository(geocodingClient: geocodingClient);

    _trip = widget.trip;
    _updateMapData();
    _checkLoginStatus();
    _loadUserInfo();
    _loadComments();
    _loadTripUpdates();
    _loadPromotionInfo();
    _loadTripAchievements();
    _initWebSocket();
  }

  Future<void> _initWebSocket() async {
    // Connect to WebSocket server first
    await _webSocketService.connect();
    // Subscribe to events for this specific trip
    final tripStream = _webSocketService.subscribeToTrip(_trip.id);
    _wsSubscription = tripStream.listen(_handleWebSocketEvent);
  }

  void _handleWebSocketEvent(WebSocketEvent event) {
    if (!mounted) return;

    switch (event.type) {
      case WebSocketEventType.tripStatusChanged:
        _handleTripStatusChanged(event as TripStatusChangedEvent);
        break;
      case WebSocketEventType.tripUpdated:
        _handleTripUpdatedEvent(event as TripUpdatedEvent);
        break;
      case WebSocketEventType.commentAdded:
        _handleCommentAdded(event as CommentAddedEvent);
        break;
      case WebSocketEventType.commentReactionAdded:
      case WebSocketEventType.commentReactionRemoved:
        _handleCommentReaction(event as CommentReactionEvent);
        break;
      case WebSocketEventType.tripSettingsUpdated:
        _handleTripSettingsUpdated(event as TripSettingsUpdatedEvent);
        break;
      default:
        break;
    }
  }

  void _handleTripStatusChanged(TripStatusChangedEvent event) {
    setState(() {
      _trip = _trip.copyWith(status: event.newStatus);
    });
  }

  void _handleTripUpdatedEvent(TripUpdatedEvent event) {
    // Add the new update to the timeline
    if (event.latitude != null && event.longitude != null) {
      final newUpdate = TripLocation(
        id: 'ws_${event.timestamp.millisecondsSinceEpoch}',
        latitude: event.latitude!,
        longitude: event.longitude!,
        timestamp: event.timestamp,
        battery: event.batteryLevel,
        message: event.message,
        city: event.city,
        country: event.country,
      );

      setState(() {
        _tripUpdates = [newUpdate, ..._tripUpdates];
      });

      // Update the map to show the new location
      _updateMapData();
    }
  }

  void _handleTripSettingsUpdated(TripSettingsUpdatedEvent event) {
    // Only update UI state from the server confirmation.
    // Background update management is already handled optimistically
    // in _handleSettingsChange to avoid duplicate stop/start cycles.
    setState(() {
      _trip = _trip.copyWith(
        automaticUpdates: event.automaticUpdates ?? _trip.automaticUpdates,
        updateRefresh: event.updateRefresh ?? _trip.updateRefresh,
      );
    });
  }

  void _handleCommentAdded(CommentAddedEvent event) {
    // Create a new comment from the event
    final newComment = Comment(
      id: event.commentId,
      tripId: _trip.id,
      userId: event.userId,
      username: event.username,
      message: event.message,
      parentCommentId: event.parentCommentId,
      individualReactions: const [],
      createdAt: event.timestamp,
      updatedAt: event.timestamp,
    );

    setState(() {
      if (event.parentCommentId != null) {
        // It's a reply
        final parentId = event.parentCommentId!;
        bool isNewReply = false;
        
        if (_replies.containsKey(parentId)) {
          // Check if reply already exists (avoid duplicates from optimistic updates)
          final existingIndex =
              _replies[parentId]!.indexWhere((c) => c.id == event.commentId);
          if (existingIndex != -1) {
            // Replace optimistic reply with server version (has correct timestamp, etc.)
            _replies[parentId]![existingIndex] = newComment;
          } else {
            // New reply from another user or WebSocket arrived before optimistic update
            _replies[parentId] = [..._replies[parentId]!, newComment];
            isNewReply = true;
          }
        } else {
          // First reply to this comment
          _replies[parentId] = [newComment];
          isNewReply = true;
        }
        
        // Update the parent comment's responsesCount if this is a new reply
        // (not an optimistic update replacement)
        if (isNewReply) {
          final parentIndex = _comments.indexWhere((c) => c.id == parentId);
          if (parentIndex != -1) {
            final parentComment = _comments[parentIndex];
            _comments[parentIndex] = Comment(
              id: parentComment.id,
              tripId: parentComment.tripId,
              userId: parentComment.userId,
              username: parentComment.username,
              userAvatarUrl: parentComment.userAvatarUrl,
              message: parentComment.message,
              parentCommentId: parentComment.parentCommentId,
              reactions: parentComment.reactions,
              individualReactions: parentComment.individualReactions,
              replies: parentComment.replies,
              reactionsCount: parentComment.reactionsCount,
              responsesCount: parentComment.responsesCount + 1,
              createdAt: parentComment.createdAt,
              updatedAt: parentComment.updatedAt,
            );
          }
        }
      } else {
        // It's a top-level comment
        // Check if comment already exists (avoid duplicates from optimistic updates)
        final existingIndex =
            _comments.indexWhere((c) => c.id == event.commentId);
        if (existingIndex != -1) {
          // Replace optimistic comment with server version (has correct timestamp, etc.)
          _comments[existingIndex] = newComment;
          _sortComments();
        } else {
          // New comment from another user or WebSocket arrived before optimistic update
          _comments.insert(0, newComment);
          _sortComments();
        }
      }
    });
  }

  void _handleCommentReaction(CommentReactionEvent event) {
    // Update local state directly from WebSocket event instead of making a GET request
    setState(() {
      // Find and update the comment in top-level comments
      final commentIndex = _comments.indexWhere((c) => c.id == event.commentId);
      if (commentIndex != -1) {
        final comment = _comments[commentIndex];
        final updatedReactions = Map<String, int>.from(comment.reactions ?? {});
        final updatedIndividualReactions =
            List<Reaction>.from(comment.individualReactions ?? []);

        if (event.isRemoval) {
          // Remove the individual reaction
          updatedIndividualReactions
              .removeWhere((r) => r.userId == event.userId);
          // Decrement reaction count
          final currentCount = updatedReactions[event.reactionType] ?? 0;
          if (currentCount > 1) {
            updatedReactions[event.reactionType] = currentCount - 1;
          } else {
            updatedReactions.remove(event.reactionType);
          }
        } else {
          // Add the individual reaction
          updatedIndividualReactions.add(Reaction(
            userId: event.userId,
            username: '', // Will be populated from full data refresh if needed
            reactionType: ReactionType.fromJson(event.reactionType),
            timestamp: DateTime.now(),
          ));
          // Increment reaction count
          updatedReactions[event.reactionType] =
              (updatedReactions[event.reactionType] ?? 0) + 1;
        }

        // Calculate new total reactions count
        final newReactionsCount =
            updatedReactions.values.fold(0, (sum, count) => sum + count);

        _comments[commentIndex] = Comment(
          id: comment.id,
          tripId: comment.tripId,
          userId: comment.userId,
          username: comment.username,
          userAvatarUrl: comment.userAvatarUrl,
          message: comment.message,
          parentCommentId: comment.parentCommentId,
          reactions: updatedReactions.isEmpty ? null : updatedReactions,
          individualReactions: updatedIndividualReactions.isEmpty
              ? null
              : updatedIndividualReactions,
          replies: comment.replies,
          reactionsCount: newReactionsCount,
          responsesCount: comment.responsesCount,
          createdAt: comment.createdAt,
          updatedAt: comment.updatedAt,
        );
        return;
      }

      // Check in replies
      for (final parentId in _replies.keys) {
        final replies = _replies[parentId]!;
        final replyIndex = replies.indexWhere((c) => c.id == event.commentId);
        if (replyIndex != -1) {
          final reply = replies[replyIndex];
          final updatedReactions = Map<String, int>.from(reply.reactions ?? {});
          final updatedIndividualReactions =
              List<Reaction>.from(reply.individualReactions ?? []);

          if (event.isRemoval) {
            updatedIndividualReactions
                .removeWhere((r) => r.userId == event.userId);
            final currentCount = updatedReactions[event.reactionType] ?? 0;
            if (currentCount > 1) {
              updatedReactions[event.reactionType] = currentCount - 1;
            } else {
              updatedReactions.remove(event.reactionType);
            }
          } else {
            updatedIndividualReactions.add(Reaction(
              userId: event.userId,
              username: '',
              reactionType: ReactionType.fromJson(event.reactionType),
              timestamp: DateTime.now(),
            ));
            updatedReactions[event.reactionType] =
                (updatedReactions[event.reactionType] ?? 0) + 1;
          }

          final newReactionsCount =
              updatedReactions.values.fold(0, (sum, count) => sum + count);

          _replies[parentId]![replyIndex] = Comment(
            id: reply.id,
            tripId: reply.tripId,
            userId: reply.userId,
            username: reply.username,
            userAvatarUrl: reply.userAvatarUrl,
            message: reply.message,
            parentCommentId: reply.parentCommentId,
            reactions: updatedReactions.isEmpty ? null : updatedReactions,
            individualReactions: updatedIndividualReactions.isEmpty
                ? null
                : updatedIndividualReactions,
            replies: reply.replies,
            reactionsCount: newReactionsCount,
            responsesCount: reply.responsesCount,
            createdAt: reply.createdAt,
            updatedAt: reply.updatedAt,
          );
          return;
        }
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize panel states based on screen size (only once)
    if (!_hasInitializedPanelStates) {
      _hasInitializedPanelStates = true;
      final screenWidth = MediaQuery.of(context).size.width;
      final isMobile = screenWidth < 600;

      if (isMobile) {
        // On mobile, collapse all panels by default so map is visible
        // Use post-frame callback to ensure setState works properly
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _isTimelineCollapsed = true;
              _isCommentsCollapsed = true;
              _isTripInfoCollapsed = true;
            });
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _wsSubscription?.cancel();
    _webSocketService.unsubscribeFromTrip(_trip.id);
    _commentController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _loadUserInfo() async {
    final username = await _repository.getCurrentUsername();
    final userId = await _repository.getCurrentUserId();
    final isAdmin = await _repository.isAdmin();

    if (userId != null) {
      await _repository.refreshUserDetails();
    }

    final displayName = await _repository.getCurrentDisplayName();
    final avatarUrl = await _repository.getCurrentAvatarUrl();

    setState(() {
      _username = username;
      _userId = userId;
      _displayName = displayName;
      _avatarUrl = avatarUrl;
      _isAdmin = isAdmin;
    });

    // If logged in and viewing another user's trip, check social status
    if (userId != null && _trip.userId != userId) {
      await _loadSocialStatus();
    }
  }

  /// Load the current user's social relationship with the trip owner
  Future<void> _loadSocialStatus() async {
    try {
      // Check if following the trip owner by looking at our following list
      final following = await _userService.getFollowing();
      final isFollowing = following.any((f) => f.followedId == _trip.userId);

      // Check if already sent a friend request to the trip owner
      final sentRequests = await _userService.getSentFriendRequests();
      final pendingRequest = sentRequests.cast<FriendRequest?>().firstWhere(
            (r) =>
                r!.receiverId == _trip.userId &&
                r.status == FriendRequestStatus.pending,
            orElse: () => null,
          );
      final hasSentRequest = pendingRequest != null;
      final requestId = pendingRequest?.id;

      // Check if already friends with the trip owner
      final friends = await _userService.getFriends();
      final isAlreadyFriends = friends.any((f) => f.friendId == _trip.userId);

      if (mounted) {
        setState(() {
          _isFollowingTripOwner = isFollowing;
          _hasSentFriendRequest = hasSentRequest;
          _sentFriendRequestId = requestId;
          _isAlreadyFriends = isAlreadyFriends;
        });
      }
    } catch (e) {
      // Silently fail - social features are optional
      debugPrint('Failed to load social status: $e');
    }
  }

  Future<void> _checkLoginStatus() async {
    final isLoggedIn = await _repository.isLoggedIn();
    setState(() {
      _isLoggedIn = isLoggedIn;
    });
  }

  Future<void> _loadTripUpdates() async {
    setState(() => _isLoadingUpdates = true);

    try {
      final updates = await _repository.loadTripUpdates(_trip.id);
      setState(() {
        _tripUpdates = updates;
        _isLoadingUpdates = false;
      });
    } catch (e) {
      setState(() => _isLoadingUpdates = false);
      if (mounted) {
        UiHelpers.showErrorMessage(context, 'Error loading updates: $e');
      }
    }
  }

  Future<void> _loadPromotionInfo() async {
    try {
      final promotion = await _promotionQueryClient.getTripPromotion(_trip.id);
      if (mounted) {
        setState(() {
          _isPromoted = true;
          _donationLink = promotion.donationLink;
        });
      }
    } catch (e) {
      // Trip is not promoted — this is expected for most trips
      if (mounted) {
        setState(() {
          _isPromoted = false;
          _donationLink = null;
        });
      }
    }
  }

  Future<void> _loadTripAchievements() async {
    try {
      final achievements =
          await _achievementService.getTripAchievements(_trip.id);
      if (mounted) {
        setState(() {
          _tripAchievements = achievements;
        });
      }
    } catch (e) {
      // Silently fail — achievements are optional
    }
  }

  Future<void> _updateMapData() async {
    try {
      final mapData = await TripMapHelper.createMapDataWithDirections(_trip);
      setState(() {
        _markers = mapData.markers;
        _polylines = mapData.polylines;
      });
    } catch (e) {
      // Fallback to straight lines if Directions API fails
      final mapData = TripMapHelper.createMapData(_trip);
      setState(() {
        _markers = mapData.markers;
        _polylines = mapData.polylines;
      });
    }
  }

  Future<void> _loadComments() async {
    setState(() => _isLoadingComments = true);

    try {
      final comments = await _repository.loadComments(_trip.id);
      setState(() {
        _comments = comments;
        _sortComments();
        _isLoadingComments = false;
      });
    } catch (e) {
      setState(() => _isLoadingComments = false);
      if (mounted) {
        UiHelpers.showErrorMessage(context, 'Error loading comments: $e');
      }
    }
  }

  void _sortComments() {
    switch (_sortOption) {
      case CommentSortOption.latest:
        _comments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case CommentSortOption.oldest:
        _comments.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case CommentSortOption.mostReplies:
        _comments.sort((a, b) => b.responsesCount.compareTo(a.responsesCount));
        break;
      case CommentSortOption.mostReactions:
        _comments.sort((a, b) => b.reactionsCount.compareTo(a.reactionsCount));
        break;
    }
  }

  void _changeSortOption(CommentSortOption option) {
    setState(() {
      _sortOption = option;
      _sortComments();
    });
  }

  Future<void> _loadReplies(String commentId) async {
    try {
      final replies = await _repository.loadReplies(commentId);
      setState(() {
        _replies[commentId] = replies;
        _expandedComments[commentId] = true;
      });
    } catch (e) {
      if (mounted) {
        UiHelpers.showErrorMessage(context, 'Error loading replies: $e');
      }
    }
  }

  Future<void> _addComment() async {
    final message = _commentController.text.trim();
    if (message.isEmpty) return;

    setState(() => _isAddingComment = true);

    try {
      String commentId;
      if (_replyingToCommentId != null) {
        // Add reply via API
        commentId = await _repository.addReply(
          _trip.id,
          _replyingToCommentId!,
          message,
        );

        // Optimistically add the reply to the UI immediately
        final optimisticReply = Comment(
          id: commentId,
          tripId: _trip.id,
          userId: _userId ?? '',
          username: _username ?? 'You',
          userAvatarUrl: _avatarUrl,
          message: message,
          parentCommentId: _replyingToCommentId,
          individualReactions: const [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        setState(() {
          final parentId = _replyingToCommentId!;
          if (!_replies.containsKey(parentId)) {
            _replies[parentId] = [];
          }
          // Check if comment already exists (shouldn't happen, but be safe)
          if (!_replies[parentId]!.any((c) => c.id == commentId)) {
            _replies[parentId] = [..._replies[parentId]!, optimisticReply];
            
            // Update the parent comment's responsesCount only when actually adding a new reply
            final parentIndex = _comments.indexWhere((c) => c.id == parentId);
            if (parentIndex != -1) {
              final parentComment = _comments[parentIndex];
              _comments[parentIndex] = Comment(
                id: parentComment.id,
                tripId: parentComment.tripId,
                userId: parentComment.userId,
                username: parentComment.username,
                userAvatarUrl: parentComment.userAvatarUrl,
                message: parentComment.message,
                parentCommentId: parentComment.parentCommentId,
                reactions: parentComment.reactions,
                individualReactions: parentComment.individualReactions,
                replies: parentComment.replies,
                reactionsCount: parentComment.reactionsCount,
                responsesCount: parentComment.responsesCount + 1,
                createdAt: parentComment.createdAt,
                updatedAt: parentComment.updatedAt,
              );
            }
          }
          
          // Ensure the replies section is expanded so the new reply is visible
          _expandedComments[parentId] = true;
          _commentController.clear();
          _replyingToCommentId = null;
        });
      } else {
        // Add top-level comment via API
        commentId = await _repository.addComment(_trip.id, message);

        // Optimistically add the comment to the UI immediately
        final optimisticComment = Comment(
          id: commentId,
          tripId: _trip.id,
          userId: _userId ?? '',
          username: _username ?? 'You',
          userAvatarUrl: _avatarUrl,
          message: message,
          parentCommentId: null,
          individualReactions: const [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        setState(() {
          // Check if comment already exists (shouldn't happen, but be safe)
          if (!_comments.any((c) => c.id == commentId)) {
            _comments.insert(0, optimisticComment);
            _sortComments();
          }
          _commentController.clear();
        });
      }

      if (mounted) {
        UiHelpers.showSuccessMessage(context, 'Comment added!');
      }
    } catch (e) {
      if (mounted) {
        UiHelpers.showErrorMessage(context, 'Error adding comment: $e');
      }
    } finally {
      setState(() => _isAddingComment = false);
    }
  }

  /// Get the current user's reaction on a comment (if any)
  ReactionType? _getUserReaction(String commentId) {
    // Check top-level comments
    final comment = _comments.firstWhere(
      (c) => c.id == commentId,
      orElse: () {
        // Check in replies
        for (final replies in _replies.values) {
          final found = replies.firstWhere(
            (r) => r.id == commentId,
            orElse: () => Comment(
              id: '',
              tripId: '',
              userId: '',
              username: '',
              message: '',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          );
          if (found.id.isNotEmpty) return found;
        }
        return Comment(
          id: '',
          tripId: '',
          userId: '',
          username: '',
          message: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      },
    );

    if (comment.id.isEmpty || comment.individualReactions == null) {
      return null;
    }

    final userReaction = comment.individualReactions!.firstWhere(
      (r) => r.userId == _userId,
      orElse: () => Reaction(
        userId: '',
        username: '',
        reactionType: ReactionType.heart,
        timestamp: DateTime.now(),
      ),
    );

    return userReaction.userId.isNotEmpty ? userReaction.reactionType : null;
  }

  Future<void> _handleReactionClick(
      String commentId, ReactionType type) async {
    final currentReaction = _getUserReaction(commentId);

    try {
      if (currentReaction == type) {
        // User clicked their existing reaction → remove it
        debugPrint(
            'Removing reaction: commentId=$commentId, type=${type.toJson()}');
        await _repository.removeReaction(commentId, type);
        if (mounted) {
          UiHelpers.showSuccessMessage(context, 'Reaction removed!');
        }
      } else if (currentReaction != null) {
        // User clicked a different reaction → backend will auto-replace
        debugPrint(
            'Replacing reaction: commentId=$commentId, from=${currentReaction.toJson()} to=${type.toJson()}');
        await _repository.addReaction(commentId, type);
        if (mounted) {
          UiHelpers.showSuccessMessage(context, 'Reaction changed!');
        }
      } else {
        // User has no reaction → add new one
        debugPrint(
            'Adding new reaction: commentId=$commentId, type=${type.toJson()}');
        await _repository.addReaction(commentId, type);
        if (mounted) {
          UiHelpers.showSuccessMessage(context, 'Reaction added!');
        }
      }
    } catch (e) {
      // Enhanced error logging for debugging backend issues
      debugPrint('Reaction error: $e');
      debugPrint(
          'Context: commentId=$commentId, targetType=${type.toJson()}, currentReaction=${currentReaction?.toJson()}');

      // Handle 409 Conflict (shouldn't happen with proper UI logic, but be safe)
      final errorMessage = e.toString();
      if (errorMessage.contains('409') || errorMessage.contains('Conflict')) {
        if (mounted) {
          UiHelpers.showInfoMessage(
              context, 'You already have this reaction on the comment');
        }
      } else if (errorMessage.contains('500')) {
        // Backend error during reaction replacement
        if (mounted) {
          UiHelpers.showErrorMessage(context,
              'Server error while changing reaction. This may be a backend issue.');
        }
      } else {
        if (mounted) {
          UiHelpers.showErrorMessage(context, 'Error with reaction: $e');
        }
      }
    }
  }

  Future<void> _addReaction(String commentId, ReactionType type) async {
    // Delegate to the new handler
    await _handleReactionClick(commentId, type);
  }

  Future<void> _changeTripStatus(TripStatus newStatus) async {
    // Validate that user is the trip owner
    if (_userId == null || _trip.userId != _userId) {
      if (mounted) {
        UiHelpers.showErrorMessage(
            context, 'Only trip owner can change status');
      }
      return;
    }

    setState(() => _isChangingStatus = true);

    try {
      await _repository.changeTripStatus(_trip.id, newStatus);

      // Update local state optimistically - WebSocket will confirm the change
      setState(() {
        _trip = _trip.copyWith(status: newStatus);
        _isChangingStatus = false;
      });

      // Manage background updates based on new status (Android only)
      if (_isAndroid) {
        final backgroundManager = BackgroundUpdateManager();
        if (newStatus == TripStatus.inProgress && _trip.automaticUpdates) {
          // Start automatic updates when trip starts/resumes AND automatic updates is enabled
          await backgroundManager.startAutoUpdates(
            _trip.id,
            _trip.name,
            _trip.effectiveUpdateRefresh,
          );
        } else {
          // Stop automatic updates when trip is paused/finished or automatic updates is disabled
          await backgroundManager.stopAutoUpdates(_trip.id);
        }
      }

      if (mounted) {
        String message;
        switch (newStatus) {
          case TripStatus.inProgress:
            message = 'Trip started!';
            break;
          case TripStatus.paused:
            message = 'Trip paused';
            break;
          case TripStatus.finished:
            message = 'Trip finished!';
            break;
          case TripStatus.created:
            message = 'Trip status updated';
            break;
        }
        UiHelpers.showSuccessMessage(context, message);
      }
    } catch (e) {
      setState(() => _isChangingStatus = false);
      if (mounted) {
        UiHelpers.showErrorMessage(context, 'Error changing status: $e');
      }
    }
  }

  Future<void> _handleSettingsChange(
      bool automaticUpdates, int? updateRefresh) async {
    // Only trip owner can change settings
    if (_userId == null || _trip.userId != _userId) {
      if (mounted) {
        UiHelpers.showErrorMessage(
            context, 'Only trip owner can change settings');
      }
      return;
    }

    setState(() => _isChangingSettings = true);

    try {
      await _repository.changeTripSettings(
        _trip.id,
        automaticUpdates,
        updateRefresh,
      );

      // Update local state optimistically - WebSocket will confirm the change
      setState(() {
        _trip = _trip.copyWith(
          automaticUpdates: automaticUpdates,
          updateRefresh: updateRefresh,
        );
        _isChangingSettings = false;
      });

      // Manage background updates based on new settings (Android only)
      if (_isAndroid && _trip.status == TripStatus.inProgress) {
        final backgroundManager = BackgroundUpdateManager();
        if (automaticUpdates && updateRefresh != null) {
          // Start/restart automatic updates with new interval
          await backgroundManager.startAutoUpdates(
              _trip.id, _trip.name, updateRefresh);
        } else {
          // Stop automatic updates when disabled
          await backgroundManager.stopAutoUpdates(_trip.id);
        }
      }

      if (mounted) {
        UiHelpers.showSuccessMessage(
            context, 'Trip settings updated successfully');
      }
    } catch (e) {
      setState(() => _isChangingSettings = false);
      if (mounted) {
        UiHelpers.showErrorMessage(context, 'Error updating settings: $e');
      }
    }
  }

  /// Trigger a one-off background update for testing (bypasses 15-min minimum)
  Future<void> _triggerTestBackgroundUpdate() async {
    final backgroundManager = BackgroundUpdateManager();
    await backgroundManager.triggerTestUpdate(_trip.id, tripName: _trip.name);
    if (mounted) {
      UiHelpers.showSuccessMessage(
        context,
        '🧪 Test background update triggered — check notifications',
      );
    }
  }

  void _showReactionPicker(String commentId) {
    showModalBottomSheet(
      context: context,
      builder: (context) => ReactionPicker(
        onReactionSelected: (type) => _addReaction(commentId, type),
      ),
    );
  }

  void _handleReply(String commentId) {
    setState(() => _replyingToCommentId = commentId);
    FocusScope.of(context).requestFocus(FocusNode());
  }

  void _handleToggleReplies(String commentId, bool isExpanded) {
    if (isExpanded) {
      setState(() => _expandedComments[commentId] = false);
    } else {
      _loadReplies(commentId);
    }
  }

  /// Handle trip update panel toggle with mobile-specific behavior
  void _handleToggleTripUpdate(bool isMobile) {
    setState(() {
      if (_isTripUpdateCollapsed) {
        // Opening
        _isTripUpdateCollapsed = false;
        if (isMobile) {
          // Close other panels on mobile
          _isTripInfoCollapsed = true;
          _isCommentsCollapsed = true;
          _isTimelineCollapsed = true;
        }
      } else {
        // Closing
        _isTripUpdateCollapsed = true;
      }
    });
  }

  Future<void> _sendManualUpdate(String? message) async {
    setState(() => _isSendingUpdate = true);

    try {
      // Ensure location permissions are granted before calling the service.
      // The service intentionally does NOT request permissions (it's a UI concern).
      final permissionReady = await _ensureLocationPermission();
      if (!permissionReady) {
        return;
      }

      final result =
          await _repository.sendTripUpdate(_trip.id, message: message);

      if (mounted) {
        if (result.isSuccess) {
          UiHelpers.showSuccessMessage(context, 'Update sent successfully!');
          // Refresh timeline to show the new update
          await _loadTripUpdates();

          // Reschedule automatic updates after manual update (Android only)
          if (_isAndroid &&
              _trip.status == TripStatus.inProgress &&
              _trip.automaticUpdates) {
            final backgroundManager = BackgroundUpdateManager();
            await backgroundManager.startAutoUpdates(
              _trip.id,
              _trip.name,
              _trip.effectiveUpdateRefresh,
            );
          }
        } else {
          UiHelpers.showErrorMessage(context, result.userMessage);
        }
      }
    } catch (e) {
      if (mounted) {
        UiHelpers.showErrorMessage(context, 'Error sending update: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSendingUpdate = false);
      }
    }
  }

  /// Ensures location permission is granted, requesting it from the user
  /// if necessary.  Returns `true` when permission is sufficient to proceed.
  Future<bool> _ensureLocationPermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      if (mounted) {
        UiHelpers.showErrorMessage(
          context,
          'Location services are disabled. '
          'Please enable GPS in your device settings.',
        );
      }
      return false;
    }

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      if (mounted) {
        UiHelpers.showErrorMessage(
          context,
          'Location permission is required to send updates.',
        );
      }
      return false;
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        UiHelpers.showErrorMessage(
          context,
          'Location permission is permanently denied. '
          'Please enable it in your device settings.',
        );
        // Try to open app settings so the user can grant permission.
        await Geolocator.openAppSettings();
      }
      return false;
    }

    return true;
  }

  /// Handle tap on a timeline update - animate map to that location
  void _handleTimelineUpdateTap(TripLocation update) {
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(update.latitude, update.longitude),
          15.0, // Zoom level for a good view of the location
        ),
      );
    }
  }

  Future<void> _logout() async {
    final confirm = await DialogHelper.showLogoutConfirmation(context);

    if (confirm) {
      await _repository.logout();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      }
    }
  }

  void _handleSettings() {
    UiHelpers.showSuccessMessage(context, 'User Settings coming soon!');
  }

  void _handleProfile() {
    AuthNavigationHelper.navigateToOwnProfile(context);
  }

  Future<void> _launchDonationLink() async {
    if (_donationLink == null) return;
    final uri = Uri.parse(_donationLink!);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      UiHelpers.showErrorMessage(context, 'Could not open donation link');
    }
  }

  Future<void> _navigateToAuth() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AuthScreen()),
    );

    // Refresh screen data after login
    if (result == true && mounted) {
      await _loadUserInfo();
      await _checkLoginStatus();
      await _loadComments(); // Reload comments in case user can now see more
      await _loadTripUpdates(); // Reload timeline
      setState(() {}); // Force rebuild to update UI
    }
  }

  Future<void> _handleFollowTripOwner() async {
    if (!_isLoggedIn || _trip.userId == _userId) return;

    // Toggle between follow and unfollow
    if (_isFollowingTripOwner) {
      try {
        await _userService.unfollowUser(_trip.userId);
        setState(() {
          _isFollowingTripOwner = false;
        });
        if (mounted) {
          UiHelpers.showSuccessMessage(
              context, 'Unfollowed @${_trip.username}');
        }
      } catch (e) {
        if (mounted) {
          UiHelpers.showErrorMessage(context, 'Failed to unfollow user: $e');
        }
      }
    } else {
      try {
        await _userService.followUser(_trip.userId);
        setState(() {
          _isFollowingTripOwner = true;
        });
        if (mounted) {
          UiHelpers.showSuccessMessage(
              context, 'You are now following @${_trip.username}');
        }
      } catch (e) {
        if (mounted) {
          UiHelpers.showErrorMessage(context, 'Failed to follow user: $e');
        }
      }
    }
  }

  Future<void> _handleSendFriendRequestToTripOwner() async {
    if (!_isLoggedIn || _trip.userId == _userId) return;

    // If already friends, allow unfriending
    if (_isAlreadyFriends) {
      try {
        await _userService.removeFriend(_trip.userId);
        setState(() {
          _isAlreadyFriends = false;
        });
        if (mounted) {
          UiHelpers.showSuccessMessage(
              context, 'You are no longer friends with @${_trip.username}');
        }
      } catch (e) {
        if (mounted) {
          UiHelpers.showErrorMessage(context, 'Failed to remove friend: $e');
        }
      }
      return;
    }

    // Cancel existing friend request
    if (_hasSentFriendRequest && _sentFriendRequestId != null) {
      try {
        await _userService.deleteFriendRequest(_sentFriendRequestId!);
        setState(() {
          _hasSentFriendRequest = false;
          _sentFriendRequestId = null;
        });
        if (mounted) {
          UiHelpers.showSuccessMessage(context, 'Friend request cancelled');
        }
      } catch (e) {
        if (mounted) {
          UiHelpers.showErrorMessage(
              context, 'Failed to cancel friend request: $e');
        }
      }
      return;
    }

    // Send new friend request
    try {
      final requestId = await _userService.sendFriendRequest(_trip.userId);
      setState(() {
        _hasSentFriendRequest = true;
        _sentFriendRequestId = requestId;
      });
      if (mounted) {
        UiHelpers.showSuccessMessage(
            context, 'Friend request sent to @${_trip.username}');
      }
    } catch (e) {
      if (mounted) {
        UiHelpers.showErrorMessage(
            context, 'Failed to send friend request: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WandererAppBar(
        searchController: _searchController,
        onSearch: () {},
        onClear: () => _searchController.clear(),
        isLoggedIn: _isLoggedIn,
        onLoginPressed: _navigateToAuth,
        username: _username,
        userId: _userId,
        displayName: _displayName,
        avatarUrl: _avatarUrl,
        onProfile: _handleProfile,
        onSettings: _handleSettings,
        onLogout: _logout,
      ),
      drawer: AppSidebar(
        username: _username,
        userId: _userId,
        displayName: _displayName,
        avatarUrl: _avatarUrl,
        selectedIndex: _selectedSidebarIndex,
        onLogout: _logout,
        onSettings: _handleSettings,
        isAdmin: _isAdmin,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Get the appropriate layout strategy based on screen size
          final isMobile =
              TripDetailLayoutStrategyFactory.isMobile(constraints.maxWidth);
          final strategy =
              TripDetailLayoutStrategyFactory.getStrategy(constraints.maxWidth);

          // Create layout data with all state and callbacks
          final layoutData = _createLayoutData(isMobile);

          // Calculate dimensions using strategy
          final leftPanelWidth =
              strategy.calculateLeftPanelWidth(constraints, layoutData);

          return Stack(
            children: [
              // Full-screen Map (background)
              Positioned.fill(
                child: TripMapView(
                  initialLocation: TripMapHelper.getInitialLocation(_trip),
                  initialZoom: TripMapHelper.getInitialZoom(_trip),
                  markers: _markers,
                  polylines: _polylines,
                  onMapCreated: (controller) => _mapController = controller,
                  isOwner: _userId != null && _trip.userId == _userId,
                  // Disable map gestures when any panel is expanded to prevent
                  // scroll-through on mobile web
                  gesturesEnabled: _isTripInfoCollapsed &&
                      _isCommentsCollapsed &&
                      _isTimelineCollapsed &&
                      _isTripUpdateCollapsed,
                ),
              ),

              // Left side: Trip Info and Comments (floating glass panels)
              Positioned(
                left: 0,
                top: 0,
                bottom: strategy.shouldLeftPanelStretchToBottom(layoutData)
                    ? 0
                    : null,
                width: leftPanelWidth,
                child: strategy.buildLeftPanel(constraints, layoutData),
              ),

              // Right side: Timeline panel (floating glass card)
              Positioned(
                right: 0,
                top: 0,
                bottom: strategy.shouldTimelinePanelStretchToBottom(layoutData)
                    ? 0
                    : null,
                child: strategy.buildTimelinePanel(constraints, layoutData),
              ),

              // Floating donation button for promoted trips
              if (_isPromoted && _donationLink != null)
                Positioned(
                  left: 16,
                  bottom: 16,
                  child: _buildDonationButton(),
                ),
            ],
          );
        },
      ),
    );
  }

  /// Builds a donation button styled based on the donation link provider
  Widget _buildDonationButton() {
    final isBuyMeACoffee =
        _donationLink != null && _donationLink!.contains('buymeacoffee.com');

    if (isBuyMeACoffee) {
      return Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFFFFDD00), // Buy me a Coffee yellow
        child: InkWell(
          onTap: _launchDonationLink,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.network(
                  'https://cdn.buymeacoffee.com/buttons/bmc-new-btn-logo.svg',
                  height: 24,
                  width: 24,
                  errorBuilder: (context, error, stackTrace) =>
                      const Text('☕', style: TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Buy me a Coffee',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Generic donation button for other providers
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(12),
      color: Colors.amber.shade700,
      child: InkWell(
        onTap: _launchDonationLink,
        borderRadius: BorderRadius.circular(12),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.favorite, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'Support this trip',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Creates the layout data object with all state and callbacks
  TripDetailLayoutData _createLayoutData(bool isMobile) {
    return TripDetailLayoutData(
      trip: _trip,
      comments: _comments,
      replies: _replies,
      expandedComments: _expandedComments,
      tripUpdates: _tripUpdates,
      isLoadingComments: _isLoadingComments,
      isLoadingUpdates: _isLoadingUpdates,
      isLoggedIn: _isLoggedIn,
      isAddingComment: _isAddingComment,
      isTimelineCollapsed: _isTimelineCollapsed,
      isCommentsCollapsed: _isCommentsCollapsed,
      isTripInfoCollapsed: _isTripInfoCollapsed,
      isTripUpdateCollapsed: _isTripUpdateCollapsed,
      isSendingUpdate: _isSendingUpdate,
      sortOption: _sortOption,
      commentController: _commentController,
      scrollController: _scrollController,
      replyingToCommentId: _replyingToCommentId,
      currentUserId: _userId,
      isChangingStatus: _isChangingStatus,
      isChangingSettings: _isChangingSettings,
      showTripUpdatePanel: _showTripUpdatePanel,
      isFollowingTripOwner: _isFollowingTripOwner,
      hasSentFriendRequest: _hasSentFriendRequest,
      isAlreadyFriends: _isAlreadyFriends,
      isPromoted: _isPromoted,
      donationLink: _donationLink,
      tripAchievements: _tripAchievements,
      onToggleTripInfo: () => _handleToggleTripInfo(isMobile),
      onToggleComments: () => _handleToggleComments(isMobile),
      onToggleTimeline: () => _handleToggleTimeline(isMobile),
      onToggleTripUpdate: () => _handleToggleTripUpdate(isMobile),
      onRefreshTimeline: _loadTripUpdates,
      onTimelineUpdateTap: _handleTimelineUpdateTap,
      onSortChanged: _changeSortOption,
      onReact: _showReactionPicker,
      onReactionChipTap: (commentId, type) =>
          _handleReactionClick(commentId, type),
      onReply: _handleReply,
      onToggleReplies: _handleToggleReplies,
      onSendComment: _addComment,
      onCancelReply: () => setState(() => _replyingToCommentId = null),
      onStatusChange: _changeTripStatus,
      onSettingsChange: _handleSettingsChange,
      onSendTripUpdate: _sendManualUpdate,
      onFollowTripOwner:
          _isLoggedIn && _trip.userId != _userId ? _handleFollowTripOwner : null,
      onSendFriendRequestToTripOwner:
          _isLoggedIn && _trip.userId != _userId ? _handleSendFriendRequestToTripOwner : null,
      onTestBackgroundUpdate:
          _isAndroid ? () => _triggerTestBackgroundUpdate() : null,
    );
  }

  /// Handle trip info panel toggle with mobile-specific behavior
  void _handleToggleTripInfo(bool isMobile) {
    setState(() {
      if (_isTripInfoCollapsed) {
        // Opening
        _isTripInfoCollapsed = false;
        if (isMobile) {
          // Close other panels on mobile
          _isCommentsCollapsed = true;
          _isTimelineCollapsed = true;
          _isTripUpdateCollapsed = true;
        }
      } else {
        // Closing
        _isTripInfoCollapsed = true;
      }
    });
  }

  /// Handle comments panel toggle with mobile-specific behavior
  void _handleToggleComments(bool isMobile) {
    setState(() {
      if (_isCommentsCollapsed) {
        // Opening
        _isCommentsCollapsed = false;
        if (isMobile) {
          // Close other panels on mobile
          _isTripInfoCollapsed = true;
          _isTimelineCollapsed = true;
          _isTripUpdateCollapsed = true;
        }
      } else {
        // Closing
        _isCommentsCollapsed = true;
      }
    });
  }

  /// Handle timeline panel toggle with mobile-specific behavior
  void _handleToggleTimeline(bool isMobile) {
    setState(() {
      if (_isTimelineCollapsed) {
        // Opening
        _isTimelineCollapsed = false;
        if (isMobile) {
          // Close other panels on mobile
          _isTripInfoCollapsed = true;
          _isCommentsCollapsed = true;
          _isTripUpdateCollapsed = true;
        }
      } else {
        // Closing
        _isTimelineCollapsed = true;
      }
    });
  }
}
