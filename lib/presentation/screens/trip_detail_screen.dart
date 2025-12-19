import 'package:flutter/material.dart' hide Visibility;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tracker_frontend/data/models/trip_models.dart';
import 'package:tracker_frontend/data/models/comment_models.dart';
import 'package:tracker_frontend/data/repositories/trip_detail_repository.dart';
import 'package:tracker_frontend/data/client/google_geocoding_api_client.dart';
import 'package:tracker_frontend/core/constants/api_endpoints.dart';
import 'package:tracker_frontend/presentation/helpers/trip_map_helper.dart';
import 'package:tracker_frontend/presentation/helpers/ui_helpers.dart';
import 'package:tracker_frontend/presentation/helpers/dialog_helper.dart';
import 'package:tracker_frontend/presentation/helpers/page_transitions.dart';
import 'package:tracker_frontend/presentation/widgets/trip_detail/reaction_picker.dart';
import 'package:tracker_frontend/presentation/widgets/trip_detail/trip_map_view.dart';
import 'package:tracker_frontend/presentation/widgets/trip_detail/trip_info_card.dart';
import 'package:tracker_frontend/presentation/widgets/trip_detail/comments_section.dart';
import 'package:tracker_frontend/presentation/widgets/trip_detail/timeline_panel.dart';
import 'package:tracker_frontend/presentation/widgets/common/wanderer_app_bar.dart';
import 'package:tracker_frontend/presentation/widgets/common/app_sidebar.dart';
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
  String? _replyingToCommentId;
  CommentSortOption _sortOption = CommentSortOption.latest;
  final int _selectedSidebarIndex = -1; // Trip detail is not a main nav item
  String? _username;
  String? _userId;

  // Collapsible panel states
  bool _isTimelineCollapsed = false;
  bool _isCommentsCollapsed = false;

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

    _trip = widget.trip;
    _updateMapData();
    _checkLoginStatus();
    _loadUserInfo();
    _loadComments();
    _loadTripUpdates();
  }

  @override
  void dispose() {
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
          return Row(
            children: [
              // Main column: Map, trip info, and comments
              Expanded(
                child: Column(
                  children: [
                    // Map takes available space
                    Expanded(
                      child: TripMapView(
                        initialLocation: TripMapHelper.getInitialLocation(
                          _trip,
                        ),
                        initialZoom: TripMapHelper.getInitialZoom(_trip),
                        markers: _markers,
                        polylines: _polylines,
                        onMapCreated: (controller) =>
                            _mapController = controller,
                      ),
                    ),
                    // Trip info section
                    TripInfoCard(trip: _trip),
                    // Comments section - flexible height based on collapsed state
                    if (_isCommentsCollapsed)
                      CommentsSection(
                        comments: _comments,
                        replies: _replies,
                        expandedComments: _expandedComments,
                        tripUserId: _trip.userId,
                        isLoading: _isLoadingComments,
                        isLoggedIn: _isLoggedIn,
                        isAddingComment: _isAddingComment,
                        isCollapsed: _isCommentsCollapsed,
                        sortOption: _sortOption,
                        commentController: _commentController,
                        scrollController: _scrollController,
                        replyingToCommentId: _replyingToCommentId,
                        onToggleCollapse: () {
                          setState(() {
                            _isCommentsCollapsed = !_isCommentsCollapsed;
                          });
                        },
                        onSortChanged: _changeSortOption,
                        onReact: _showReactionPicker,
                        onReply: _handleReply,
                        onToggleReplies: _handleToggleReplies,
                        onSendComment: _addComment,
                        onCancelReply: () {
                          setState(() => _replyingToCommentId = null);
                        },
                      )
                    else
                      Expanded(
                        flex: 1,
                        child: CommentsSection(
                          comments: _comments,
                          replies: _replies,
                          expandedComments: _expandedComments,
                          tripUserId: _trip.userId,
                          isLoading: _isLoadingComments,
                          isLoggedIn: _isLoggedIn,
                          isAddingComment: _isAddingComment,
                          isCollapsed: _isCommentsCollapsed,
                          sortOption: _sortOption,
                          commentController: _commentController,
                          scrollController: _scrollController,
                          replyingToCommentId: _replyingToCommentId,
                          onToggleCollapse: () {
                            setState(() {
                              _isCommentsCollapsed = !_isCommentsCollapsed;
                            });
                          },
                          onSortChanged: _changeSortOption,
                          onReact: _showReactionPicker,
                          onReply: _handleReply,
                          onToggleReplies: _handleToggleReplies,
                          onSendComment: _addComment,
                          onCancelReply: () {
                            setState(() => _replyingToCommentId = null);
                          },
                        ),
                      ),
                  ],
                ),
              ),
              // Timeline panel - width based on collapsed state
              TimelinePanel(
                updates: _tripUpdates,
                isLoading: _isLoadingUpdates,
                isCollapsed: _isTimelineCollapsed,
                onToggleCollapse: () {
                  setState(() {
                    _isTimelineCollapsed = !_isTimelineCollapsed;
                  });
                },
                onRefresh: _loadTripUpdates,
              ),
            ],
          );
        },
      ),
    );
  }
}
