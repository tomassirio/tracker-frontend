import 'package:flutter/material.dart' hide Visibility;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tracker_frontend/data/models/trip_models.dart';
import 'package:tracker_frontend/data/models/comment_models.dart';
import 'package:tracker_frontend/data/repositories/trip_detail_repository.dart';
import 'package:tracker_frontend/data/client/google_geocoding_api_client.dart';
import 'package:tracker_frontend/data/services/trip_update_manager.dart';
import 'package:tracker_frontend/core/constants/api_endpoints.dart';
import 'package:tracker_frontend/core/constants/enums.dart';
import 'package:tracker_frontend/presentation/helpers/trip_map_helper.dart';
import 'package:tracker_frontend/presentation/helpers/ui_helpers.dart';
import 'package:tracker_frontend/presentation/helpers/dialog_helper.dart';
import 'package:tracker_frontend/presentation/helpers/page_transitions.dart';
import 'package:tracker_frontend/presentation/widgets/trip_detail/reaction_picker.dart';
import 'package:tracker_frontend/presentation/widgets/trip_detail/trip_map_view.dart';
import 'package:tracker_frontend/presentation/widgets/trip_detail/comments_section.dart';
import 'package:tracker_frontend/presentation/widgets/trip_detail/manual_trip_update_dialog.dart';
import 'package:tracker_frontend/presentation/widgets/common/wanderer_app_bar.dart';
import 'package:tracker_frontend/presentation/widgets/common/app_sidebar.dart';
import 'package:tracker_frontend/presentation/strategies/trip_detail_layout_strategy.dart';
import 'auth_screen.dart';
import 'profile_screen.dart';

/// Trip detail screen showing trip info, map, and comments
class TripDetailScreen extends StatefulWidget {
  final Trip trip;

  const TripDetailScreen({super.key, required this.trip});

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  late final TripDetailRepository _repository;
  late final TripUpdateManager _updateManager;
  final TextEditingController _searchController = TextEditingController();
  GoogleMapController? _mapController;
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

  // Collapsible panel states
  bool _isTimelineCollapsed = false;
  bool _isCommentsCollapsed = false;
  bool _isTripInfoCollapsed = false;
  bool _hasInitializedPanelStates = false;

  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Initialize repository with geocoding client for place enrichment
    final apiKey = ApiEndpoints.googleMapsApiKey;
    final geocodingClient =
        apiKey.isNotEmpty ? GoogleGeocodingApiClient(apiKey) : null;
    _repository = TripDetailRepository(geocodingClient: geocodingClient);
    _updateManager = TripUpdateManager();

    _trip = widget.trip;
    _updateMapData();
    _checkLoginStatus();
    _loadUserInfo();
    _loadComments();
    _loadTripUpdates();
    _initializeAutomaticUpdates();
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
    _commentController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    _mapController?.dispose();
    // Stop automatic updates when leaving the screen
    _updateManager.stopAutomaticUpdates(_trip.id);
    super.dispose();
  }

  Future<void> _loadUserInfo() async {
    final username = await _repository.getCurrentUsername();
    final userId = await _repository.getCurrentUserId();

    setState(() {
      _username = username;
      _userId = userId;
    });
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

  /// Initialize automatic updates based on trip status
  Future<void> _initializeAutomaticUpdates() async {
    // Only start automatic updates if trip is in progress
    if (_trip.status == TripStatus.inProgress && _trip.updateRefresh != null) {
      try {
        // Request location permissions if not already granted
        final hasPermission = await _updateManager.hasLocationPermissions();
        if (!hasPermission) {
          final granted = await _updateManager.requestLocationPermissions();
          if (!granted && mounted) {
            UiHelpers.showErrorMessage(
              context,
              'Location permissions are required for automatic updates',
            );
            return;
          }
        }
        
        // Start automatic updates
        await _updateManager.startAutomaticUpdates(_trip);
      } catch (e) {
        if (mounted) {
          UiHelpers.showErrorMessage(
            context,
            'Error starting automatic updates: $e',
          );
        }
      }
    }
  }

  /// Show manual trip update dialog
  Future<void> _showManualUpdateDialog() async {
    // Check if user is trip owner
    if (_userId == null || _trip.userId != _userId) {
      if (mounted) {
        UiHelpers.showErrorMessage(
          context,
          'Only trip owner can send updates',
        );
      }
      return;
    }

    // Show dialog
    showDialog(
      context: context,
      builder: (context) => ManualTripUpdateDialog(
        onSendUpdate: (message) => _sendManualUpdate(message),
      ),
    );
  }

  /// Send a manual trip update with user's message
  Future<void> _sendManualUpdate(String message) async {
    try {
      await _updateManager.sendManualUpdate(
        tripId: _trip.id,
        message: message,
      );
      
      // Reload trip updates to show the new one
      await _loadTripUpdates();
      
      // Refresh the trip to get latest data
      final updatedTrip = await _repository.loadTrip(_trip.id);
      setState(() {
        _trip = updatedTrip;
      });
      await _updateMapData();
    } catch (e) {
      rethrow; // Let the dialog handle the error
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
        final reply = await _repository.addReply(
          _trip.id,
          _replyingToCommentId!,
          message,
        );

        setState(() {
          _replies[_replyingToCommentId!] = [
            ...?_replies[_replyingToCommentId!],
            reply,
          ];
          _commentController.clear();
          _replyingToCommentId = null;
        });
      } else {
        final comment = await _repository.addComment(_trip.id, message);

        setState(() {
          _comments.insert(0, comment);
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
      final updatedTrip =
          await _repository.changeTripStatus(_trip.id, newStatus);

      setState(() {
        // Preserve username if backend didn't return it
        if (updatedTrip.username.isEmpty && _trip.username.isNotEmpty) {
          _trip = updatedTrip.copyWith(username: _trip.username);
        } else {
          _trip = updatedTrip;
        }
        _isChangingStatus = false;
      });

      // Handle automatic updates based on status
      if (newStatus == TripStatus.inProgress) {
        // Start automatic updates when trip starts
        await _initializeAutomaticUpdates();
      } else {
        // Stop automatic updates when trip is paused or finished
        await _updateManager.stopAutomaticUpdates(_trip.id);
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

  Future<void> _logout() async {
    final confirm = await DialogHelper.showLogoutConfirmation(context);

    if (confirm) {
      await _repository.logout();
      if (mounted) {
        // Pop with result to trigger refresh in home screen
        Navigator.pop(context, true);
      }
    }
  }

  void _handleSettings() {
    UiHelpers.showSuccessMessage(context, 'User Settings coming soon!');
  }

  void _handleProfile() {
    Navigator.push(
      context,
      PageTransitions.slideRight(const ProfileScreen()),
    ).then((result) {
      if (result == true && mounted) {
        // User logged out from profile screen
        Navigator.pop(context, true); // Go back to home with logout signal
      }
    });
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
      floatingActionButton: _shouldShowManualUpdateButton()
          ? FloatingActionButton.extended(
              onPressed: _showManualUpdateDialog,
              icon: const Icon(Icons.add_location),
              label: const Text('Send Update'),
              backgroundColor: Theme.of(context).primaryColor,
            )
          : null,
    );
  }

  /// Check if manual update button should be shown
  /// Only show if user is trip owner and trip is in progress or paused
  bool _shouldShowManualUpdateButton() {
    if (_userId == null || _trip.userId != _userId) {
      return false;
    }
    return _trip.status == TripStatus.inProgress ||
        _trip.status == TripStatus.paused;
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
      sortOption: _sortOption,
      commentController: _commentController,
      scrollController: _scrollController,
      replyingToCommentId: _replyingToCommentId,
      currentUserId: _userId,
      isChangingStatus: _isChangingStatus,
      onToggleTripInfo: () => _handleToggleTripInfo(isMobile),
      onToggleComments: () => _handleToggleComments(isMobile),
      onToggleTimeline: () => _handleToggleTimeline(isMobile),
      onRefreshTimeline: _loadTripUpdates,
      onSortChanged: _changeSortOption,
      onReact: _showReactionPicker,
      onReply: _handleReply,
      onToggleReplies: _handleToggleReplies,
      onSendComment: _addComment,
      onCancelReply: () => setState(() => _replyingToCommentId = null),
      onStatusChange: _changeTripStatus,
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
