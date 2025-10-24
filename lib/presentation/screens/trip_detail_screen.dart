import 'package:flutter/material.dart' hide Visibility;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tracker_frontend/core/constants/enums.dart';
import 'package:tracker_frontend/data/models/trip_models.dart';
import 'package:tracker_frontend/data/models/comment_models.dart';
import 'package:tracker_frontend/data/repositories/trip_detail_repository.dart';
import 'package:tracker_frontend/presentation/helpers/trip_map_helper.dart';
import 'package:tracker_frontend/presentation/helpers/ui_helpers.dart';
import 'package:tracker_frontend/presentation/widgets/trip_detail/comment_input.dart';
import 'package:tracker_frontend/presentation/widgets/trip_detail/comment_card.dart';
import 'package:tracker_frontend/presentation/widgets/trip_detail/reaction_picker.dart';
import 'package:tracker_frontend/presentation/widgets/trip_detail/trip_map_view.dart';

/// Trip detail screen showing trip info, map, and comments
class TripDetailScreen extends StatefulWidget {
  final Trip trip;

  const TripDetailScreen({super.key, required this.trip});

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

enum CommentSortOption { latest, oldest, mostReplies, mostReactions }

class _TripDetailScreenState extends State<TripDetailScreen> {
  final TripDetailRepository _repository = TripDetailRepository();
  GoogleMapController? _mapController;
  late Trip _trip;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  List<Comment> _comments = [];
  final Map<String, List<Comment>> _replies = {};
  final Map<String, bool> _expandedComments = {};

  bool _isLoadingComments = false;
  bool _isAddingComment = false;
  bool _isLoggedIn = false;
  String? _replyingToCommentId;
  CommentSortOption _sortOption = CommentSortOption.latest;

  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _trip = widget.trip;
    _updateMapData();
    _checkLoginStatus();
    _loadComments();
  }

  Future<void> _checkLoginStatus() async {
    final isLoggedIn = await _repository.isLoggedIn();
    setState(() {
      _isLoggedIn = isLoggedIn;
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _updateMapData() {
    final mapData = TripMapHelper.createMapData(_trip);
    setState(() {
      _markers = mapData.markers;
      _polylines = mapData.polylines;
    });
  }

  Future<void> _loadComments() async {
    setState(() => _isLoadingComments = true);

    try {
      final comments = await _repository.loadComments(_trip);
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
      final replies = await _repository.loadReplies(_comments, commentId);
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
    try {
      final updatedTrip = await _repository.changeTripStatus(
        _trip.id,
        newStatus,
      );

      setState(() => _trip = updatedTrip);

      if (mounted) {
        UiHelpers.showSuccessMessage(
          context,
          'Trip status changed to ${newStatus.toJson()}',
        );
      }
    } catch (e) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_trip.name),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Map takes most of the space (like YouTube video)
          Expanded(
            flex: 3,
            child: Column(
              children: [
                // Map view
                Expanded(
                  child: TripMapView(
                    initialLocation: TripMapHelper.getInitialLocation(_trip),
                    initialZoom: TripMapHelper.getInitialZoom(_trip),
                    markers: _markers,
                    polylines: _polylines,
                    onMapCreated: (controller) => _mapController = controller,
                  ),
                ),
                // Timeline placeholder
                Container(
                  height: 60,
                  color: Colors.grey[200],
                  child: Center(
                    child: Text(
                      'Timeline (Coming Soon)',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Trip info section (between map and comments)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _trip.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      child: Text(_trip.username[0].toUpperCase()),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _trip.username,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Chip(
                      label: Text(
                        _trip.status.toJson().toUpperCase(),
                        style: const TextStyle(fontSize: 11),
                      ),
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.comment, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${_trip.commentsCount} comments',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.visibility, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      _trip.visibility.toJson(),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                if (_trip.description != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _trip.description!,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ],
            ),
          ),
          // Comments section header with sort options
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              children: [
                Text(
                  '${_comments.length} Comments',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                PopupMenuButton<CommentSortOption>(
                  icon: const Icon(Icons.sort),
                  onSelected: _changeSortOption,
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: CommentSortOption.latest,
                      child: Text('Latest first'),
                    ),
                    const PopupMenuItem(
                      value: CommentSortOption.oldest,
                      child: Text('Oldest first'),
                    ),
                    const PopupMenuItem(
                      value: CommentSortOption.mostReplies,
                      child: Text('Most replies'),
                    ),
                    const PopupMenuItem(
                      value: CommentSortOption.mostReactions,
                      child: Text('Most reactions'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Comments list
          Expanded(
            flex: 2,
            child: _isLoadingComments
                ? const Center(child: CircularProgressIndicator())
                : _comments.isEmpty
                    ? _buildEmptyCommentsState()
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: _comments.length,
                        itemBuilder: (context, index) {
                          final comment = _comments[index];
                          final isExpanded =
                              _expandedComments[comment.id] ?? false;
                          final commentReplies = _replies[comment.id] ?? [];

                          return CommentCard(
                            comment: comment,
                            tripUserId: _trip.userId,
                            isExpanded: isExpanded,
                            replies: commentReplies,
                            onReact: () => _showReactionPicker(comment.id),
                            onReply: () => _handleReply(comment.id),
                            onToggleReplies: () =>
                                _handleToggleReplies(comment.id, isExpanded),
                          );
                        },
                      ),
          ),
          // Comment input (disabled if not logged in)
          if (_isLoggedIn)
            CommentInput(
              controller: _commentController,
              isAddingComment: _isAddingComment,
              isReplyMode: _replyingToCommentId != null,
              onSend: _addComment,
              onCancelReply: () {
                setState(() => _replyingToCommentId = null);
              },
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              child: const Center(
                child: Text(
                  'Please log in to comment',
                  style: TextStyle(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyCommentsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.comment_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No comments yet',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              _isLoggedIn
                  ? 'Be the first to comment!'
                  : 'Log in to add a comment',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}
