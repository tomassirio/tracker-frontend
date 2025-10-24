import 'package:flutter/material.dart' hide Visibility;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tracker_frontend/core/constants/enums.dart';
import 'package:tracker_frontend/data/models/trip_models.dart';
import 'package:tracker_frontend/data/models/comment_models.dart';
import 'package:tracker_frontend/data/repositories/trip_detail_repository.dart';
import 'package:tracker_frontend/presentation/helpers/trip_map_helper.dart';
import 'package:tracker_frontend/presentation/helpers/ui_helpers.dart';
import 'package:tracker_frontend/presentation/widgets/trip_detail/comment_input.dart';
import 'package:tracker_frontend/presentation/widgets/trip_detail/comments_section.dart';
import 'package:tracker_frontend/presentation/widgets/trip_detail/reaction_picker.dart';
import 'package:tracker_frontend/presentation/widgets/trip_detail/trip_info_card.dart';
import 'package:tracker_frontend/presentation/widgets/trip_detail/trip_map_view.dart';
import 'package:tracker_frontend/presentation/widgets/trip_detail/trip_status_menu.dart';

/// Trip detail screen showing trip info, map, and comments
class TripDetailScreen extends StatefulWidget {
  final Trip trip;

  const TripDetailScreen({super.key, required this.trip});

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  final TripDetailRepository _repository = TripDetailRepository();
  GoogleMapController? _mapController;
  late Trip _trip;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  List<Comment> _comments = [];
  Map<String, List<Comment>> _replies = {};
  Map<String, bool> _expandedComments = {};

  bool _isLoadingComments = false;
  bool _isAddingComment = false;
  String? _replyingToCommentId;

  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _trip = widget.trip;
    _updateMapData();
    _loadComments();
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
        _isLoadingComments = false;
      });
    } catch (e) {
      setState(() => _isLoadingComments = false);
      if (mounted) {
        UiHelpers.showErrorMessage(context, 'Error loading comments: $e');
      }
    }
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
        actions: [TripStatusMenu(onStatusChanged: _changeTripStatus)],
      ),
      body: Column(
        children: [
          TripInfoCard(trip: _trip),
          TripMapView(
            initialLocation: TripMapHelper.getInitialLocation(_trip),
            initialZoom: TripMapHelper.getInitialZoom(_trip),
            markers: _markers,
            polylines: _polylines,
            onMapCreated: (controller) => _mapController = controller,
          ),
          Expanded(
            child: CommentsSection(
              isLoading: _isLoadingComments,
              comments: _comments,
              expandedComments: _expandedComments,
              replies: _replies,
              tripUserId: _trip.userId,
              scrollController: _scrollController,
              onReact: _showReactionPicker,
              onReply: _handleReply,
              onToggleReplies: _handleToggleReplies,
            ),
          ),
          CommentInput(
            controller: _commentController,
            isAddingComment: _isAddingComment,
            isReplyMode: _replyingToCommentId != null,
            onSend: _addComment,
            onCancelReply: () {
              setState(() => _replyingToCommentId = null);
            },
          ),
        ],
      ),
    );
  }
}
