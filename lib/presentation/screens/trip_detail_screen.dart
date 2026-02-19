import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart' hide Visibility;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tracker_frontend/data/models/trip_models.dart';
import 'package:tracker_frontend/data/models/user_models.dart';
import 'package:tracker_frontend/data/models/comment_models.dart';
import 'package:tracker_frontend/data/models/websocket/websocket_event.dart';
import 'package:tracker_frontend/data/repositories/trip_detail_repository.dart';
import 'package:tracker_frontend/data/client/google_geocoding_api_client.dart';
import 'package:tracker_frontend/data/services/websocket_service.dart';
import 'package:tracker_frontend/data/services/user_service.dart';
import 'package:tracker_frontend/core/constants/api_endpoints.dart';
import 'package:tracker_frontend/core/constants/enums.dart';
import 'package:tracker_frontend/core/services/background_update_manager.dart';
import 'package:tracker_frontend/presentation/helpers/trip_map_helper.dart';
import 'package:tracker_frontend/presentation/helpers/ui_helpers.dart';
import 'package:tracker_frontend/presentation/helpers/dialog_helper.dart';
import 'package:tracker_frontend/presentation/helpers/auth_navigation_helper.dart';
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
  bool _isChangingStatus = false;
  String? _replyingToCommentId;
  CommentSortOption _sortOption = CommentSortOption.latest;
  final int _selectedSidebarIndex = -1; // Trip detail is not a main nav item
  String? _username;
  String? _userId;

  // Track social interactions
  bool _isFollowingTripOwner = false;
  bool _hasSentFriendRequest = false;
  bool _isAlreadyFriends = false;
  String? _sentFriendRequestId; // Store the request ID for cancellation

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

  void _handleCommentAdded(CommentAddedEvent event) {
    // Create a new comment from the event
    final newComment = Comment(
      id: event.commentId,
      tripId: _trip.id,
      userId: event.userId,
      username: event.username,
      message: event.message,
      parentCommentId: event.parentCommentId,
      createdAt: event.timestamp,
      updatedAt: event.timestamp,
    );

    setState(() {
      if (event.parentCommentId != null) {
        // It's a reply
        final parentId = event.parentCommentId!;
        if (_replies.containsKey(parentId)) {
          _replies[parentId] = [..._replies[parentId]!, newComment];
        }
      } else {
        // It's a top-level comment
        _comments.insert(0, newComment);
        _sortComments();
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

        if (event.isRemoval) {
          // Decrement reaction count
          final currentCount = updatedReactions[event.reactionType] ?? 0;
          if (currentCount > 1) {
            updatedReactions[event.reactionType] = currentCount - 1;
          } else {
            updatedReactions.remove(event.reactionType);
          }
        } else {
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

          if (event.isRemoval) {
            final currentCount = updatedReactions[event.reactionType] ?? 0;
            if (currentCount > 1) {
              updatedReactions[event.reactionType] = currentCount - 1;
            } else {
              updatedReactions.remove(event.reactionType);
            }
          } else {
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

    setState(() {
      _username = username;
      _userId = userId;
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
      if (_replyingToCommentId != null) {
        await _repository.addReply(
          _trip.id,
          _replyingToCommentId!,
          message,
        );

        // Clear the reply state - the comment will arrive via WebSocket
        setState(() {
          _commentController.clear();
          _replyingToCommentId = null;
        });
      } else {
        await _repository.addComment(_trip.id, message);

        // Clear the input - the comment will arrive via WebSocket
        setState(() {
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

  Future<void> _addReaction(String commentId, ReactionType type) async {
    try {
      await _repository.addReaction(commentId, type);

      if (mounted) {
        UiHelpers.showSuccessMessage(context, 'Reaction added!');
      }
    } catch (e) {
      if (mounted) {
        UiHelpers.showErrorMessage(context, 'Error adding reaction: $e');
      }
    }
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
        if (newStatus == TripStatus.inProgress) {
          // Start automatic updates when trip starts/resumes
          await backgroundManager.startAutoUpdates(
            _trip.id,
            _trip.effectiveUpdateRefresh,
          );
        } else {
          // Stop automatic updates when trip is paused/finished
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

  void _handleToggleTripUpdate() {
    setState(() => _isTripUpdateCollapsed = !_isTripUpdateCollapsed);
  }

  Future<void> _sendManualUpdate(String? message) async {
    setState(() => _isSendingUpdate = true);

    try {
      final success =
          await _repository.sendTripUpdate(_trip.id, message: message);

      if (mounted) {
        if (success) {
          UiHelpers.showSuccessMessage(context, 'Update sent successfully!');
          // Refresh timeline to show the new update
          await _loadTripUpdates();
        } else {
          UiHelpers.showErrorMessage(
            context,
            'Failed to send update. Check location permissions.',
          );
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
        onProfile: _handleProfile,
        onSettings: _handleSettings,
        onLogout: _logout,
      ),
      drawer: AppSidebar(
        username: _username,
        userId: _userId,
        selectedIndex: _selectedSidebarIndex,
        onLogout: _logout,
        onSettings: _handleSettings,
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
            ],
          );
        },
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
      showTripUpdatePanel: _showTripUpdatePanel,
      isFollowingTripOwner: _isFollowingTripOwner,
      hasSentFriendRequest: _hasSentFriendRequest,
      isAlreadyFriends: _isAlreadyFriends,
      onToggleTripInfo: () => _handleToggleTripInfo(isMobile),
      onToggleComments: () => _handleToggleComments(isMobile),
      onToggleTimeline: () => _handleToggleTimeline(isMobile),
      onToggleTripUpdate: _handleToggleTripUpdate,
      onRefreshTimeline: _loadTripUpdates,
      onTimelineUpdateTap: _handleTimelineUpdateTap,
      onSortChanged: _changeSortOption,
      onReact: _showReactionPicker,
      onReply: _handleReply,
      onToggleReplies: _handleToggleReplies,
      onSendComment: _addComment,
      onCancelReply: () => setState(() => _replyingToCommentId = null),
      onStatusChange: _changeTripStatus,
      onSendTripUpdate: _sendManualUpdate,
      onFollowTripOwner:
          _trip.userId != _userId ? _handleFollowTripOwner : null,
      onSendFriendRequestToTripOwner:
          _trip.userId != _userId ? _handleSendFriendRequestToTripOwner : null,
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
        }
      } else {
        // Closing
        _isTimelineCollapsed = true;
      }
    });
  }
}
