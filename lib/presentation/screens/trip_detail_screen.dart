import 'package:flutter/material.dart' hide Visibility;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tracker_frontend/core/constants/enums.dart';
import 'package:tracker_frontend/data/models/trip_models.dart';
import 'package:tracker_frontend/data/models/comment_models.dart';
import 'package:tracker_frontend/data/services/trip_service.dart';
import 'package:tracker_frontend/data/services/comment_service.dart';

/// Trip detail screen showing trip info, map, and comments
class TripDetailScreen extends StatefulWidget {
  final Trip trip;

  const TripDetailScreen({super.key, required this.trip});

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  final TripService _tripService = TripService();
  final CommentService _commentService = CommentService();
  GoogleMapController? _mapController;
  late Trip _trip;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  List<Comment> _comments = [];
  Map<String, List<Comment>> _replies = {}; // commentId -> replies
  Map<String, bool> _expandedComments = {}; // commentId -> isExpanded
  Map<String, List<Reaction>> _reactions = {}; // commentId -> reactions

  bool _isLoadingComments = false;
  bool _isAddingComment = false;
  String? _replyingToCommentId;

  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _trip = widget.trip;
    _updateMapMarkers();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _updateMapMarkers() {
    _markers.clear();
    _polylines.clear();

    if (_trip.locations != null && _trip.locations!.isNotEmpty) {
      final locations = _trip.locations!;
      final points = <LatLng>[];

      for (int i = 0; i < locations.length; i++) {
        final location = locations[i];
        final position = LatLng(location.latitude, location.longitude);
        points.add(position);

        _markers.add(
          Marker(
            markerId: MarkerId(location.id),
            position: position,
            infoWindow: InfoWindow(
              title: 'Update ${i + 1}',
              snippet: location.message ?? 'Location update',
            ),
            icon: i == locations.length - 1
                ? BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueGreen,
                  )
                : BitmapDescriptor.defaultMarker,
          ),
        );
      }

      if (points.length > 1) {
        _polylines.add(
          Polyline(
            polylineId: const PolylineId('route'),
            points: points,
            color: Colors.blue,
            width: 3,
          ),
        );
      }
    }

    setState(() {});
  }

  Future<void> _loadComments() async {
    setState(() {
      _isLoadingComments = true;
    });

    try {
      final allComments = _trip.comments ?? [];
      setState(() {
        _comments = allComments.where((c) => c.parentCommentId == null).toList();
        _isLoadingComments = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingComments = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading comments: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadReplies(String commentId) async {
    try {
      // Find the comment and use its nested replies
      final comment = _comments.firstWhere((c) => c.id == commentId);
      final replies = comment.replies ?? [];
      setState(() {
        _replies[commentId] = replies;
        _expandedComments[commentId] = true;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading replies: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadReactions(String commentId) async {
    try {
      final reactions = await _commentService.getCommentReactions(_trip.id, commentId);
      setState(() {
        _reactions[commentId] = reactions;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading reactions: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _addComment() async {
    final message = _commentController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _isAddingComment = true;
    });

    try {
      if (_replyingToCommentId != null) {
        // Add reply
        final reply = await _commentService.replyToComment(
          _trip.id,
          _replyingToCommentId!,
          CreateCommentResponseRequest(message: message),
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
        // Add top-level comment
        final comment = await _commentService.addComment(
          _trip.id,
          CreateCommentRequest(message: message),
        );

        setState(() {
          _comments.insert(0, comment);
          _commentController.clear();
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comment added!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding comment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isAddingComment = false;
      });
    }
  }

  Future<void> _addReaction(String commentId, ReactionType type) async {
    try {
      await _commentService.addReaction(
        _trip.id,
        commentId,
        AddReactionRequest(type: type),
      );

      // Reload reactions
      await _loadReactions(commentId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reaction added!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding reaction: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _changeTripStatus(TripStatus newStatus) async {
    try {
      final request = ChangeStatusRequest(status: newStatus);
      final updatedTrip = await _tripService.changeStatus(_trip.id, request);

      setState(() {
        _trip = updatedTrip;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Trip status changed to ${newStatus.toJson()}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error changing status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasLocations = _trip.locations != null && _trip.locations!.isNotEmpty;
    final initialLocation = hasLocations
        ? LatLng(
            _trip.locations!.first.latitude,
            _trip.locations!.first.longitude,
          )
        : const LatLng(40.7128, -74.0060); // Default to NYC

    return Scaffold(
      appBar: AppBar(
        title: Text(_trip.name),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          PopupMenuButton<TripStatus>(
            icon: const Icon(Icons.more_vert),
            onSelected: _changeTripStatus,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: TripStatus.in_progress,
                child: Row(
                  children: [
                    Icon(Icons.play_arrow, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Start Trip'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: TripStatus.paused,
                child: Row(
                  children: [
                    Icon(Icons.pause, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Pause Trip'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: TripStatus.finished,
                child: Row(
                  children: [
                    Icon(Icons.check, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('Finish Trip'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Trip info card
          Card(
            margin: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_trip.description != null) ...[
                    Text(
                      _trip.description!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                  ],
                  Row(
                    children: [
                      Chip(
                        label: Text(_trip.status.toJson()),
                        avatar: Icon(
                          _getStatusIcon(_trip.status),
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Chip(
                        label: Text(_trip.visibility.toJson()),
                        avatar: Icon(
                          _getVisibilityIcon(_trip.visibility),
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                  if (hasLocations) ...[
                    const SizedBox(height: 8),
                    Text(
                      '${_trip.locations!.length} location update(s)',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
          ),
          // Map
          SizedBox(
            height: 200,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: initialLocation,
                zoom: hasLocations ? 12 : 4,
              ),
              markers: _markers,
              polylines: _polylines,
              onMapCreated: (controller) {
                _mapController = controller;
              },
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
            ),
          ),
          // Comments section
          Expanded(
            child: Column(
              children: [
                // Comments header
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.comment, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Comments (${_comments.length})',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
                // Comments list
                Expanded(
                  child: _isLoadingComments
                      ? const Center(child: CircularProgressIndicator())
                      : _comments.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.comment_outlined,
                                      size: 64,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No comments yet',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Be the first to comment!',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              itemCount: _comments.length,
                              itemBuilder: (context, index) {
                                return _buildCommentCard(_comments[index]);
                              },
                            ),
                ),
              ],
            ),
          ),
          // Add comment section
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_replyingToCommentId != null) ...[
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.reply, size: 16, color: Colors.blue),
                        const SizedBox(width: 8),
                        const Text('Replying to comment'),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () {
                            setState(() {
                              _replyingToCommentId = null;
                            });
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        decoration: InputDecoration(
                          hintText: _replyingToCommentId != null
                              ? 'Write a reply...'
                              : 'Add a comment...',
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _addComment(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _isAddingComment ? null : _addComment,
                      icon: _isAddingComment
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.send),
                      style: IconButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentCard(Comment comment) {
    final isOwner = comment.userId == _trip.userId;
    final isExpanded = _expandedComments[comment.id] ?? false;
    final replies = _replies[comment.id] ?? [];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: isOwner ? Colors.amber[50] : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Comment header
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: isOwner ? Colors.amber : Colors.blue,
                  child: Text(
                    comment.username[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            comment.username,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          if (isOwner) ...[
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Owner',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.amber[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        _formatDateTime(comment.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Comment message
            Text(
              comment.message,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            // Comment actions
            Row(
              children: [
                // Reaction button
                TextButton.icon(
                  onPressed: () => _showReactionPicker(comment.id),
                  icon: const Icon(Icons.thumb_up_outlined, size: 16),
                  label: Text(
                    comment.reactionsCount > 0
                        ? '${comment.reactionsCount}'
                        : 'React',
                    style: const TextStyle(fontSize: 12),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                const SizedBox(width: 8),
                // Reply button
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _replyingToCommentId = comment.id;
                    });
                    FocusScope.of(context).requestFocus(FocusNode());
                  },
                  icon: const Icon(Icons.reply, size: 16),
                  label: const Text('Reply', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                if (comment.responsesCount > 0) ...[
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () {
                      if (isExpanded) {
                        setState(() {
                          _expandedComments[comment.id] = false;
                        });
                      } else {
                        _loadReplies(comment.id);
                      }
                    },
                    icon: Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      size: 16,
                    ),
                    label: Text(
                      '${comment.responsesCount} ${comment.responsesCount == 1 ? 'reply' : 'replies'}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ],
            ),
            // Replies
            if (isExpanded && replies.isNotEmpty) ...[
              const Divider(),
              ...replies.map((reply) => _buildReplyCard(reply)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReplyCard(Comment reply) {
    final isOwner = reply.userId == _trip.userId;

    return Container(
      margin: const EdgeInsets.only(left: 24, top: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isOwner ? Colors.amber[100] : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: isOwner ? Colors.amber : Colors.blue,
                child: Text(
                  reply.username[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Row(
                  children: [
                    Text(
                      reply.username,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    if (isOwner) ...[
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.star,
                        size: 12,
                        color: Colors.amber,
                      ),
                    ],
                    const SizedBox(width: 8),
                    Text(
                      _formatDateTime(reply.createdAt),
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            reply.message,
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }

  void _showReactionPicker(String commentId) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'React to this comment',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildReactionButton('👍', ReactionType.like, commentId),
                _buildReactionButton('❤️', ReactionType.love, commentId),
                _buildReactionButton('😮', ReactionType.wow, commentId),
                _buildReactionButton('😂', ReactionType.haha, commentId),
                _buildReactionButton('😢', ReactionType.sad, commentId),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildReactionButton(String emoji, ReactionType type, String commentId) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        _addReaction(commentId, type);
      },
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(25),
        ),
        child: Center(
          child: Text(
            emoji,
            style: const TextStyle(fontSize: 28),
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  IconData _getStatusIcon(TripStatus status) {
    switch (status) {
      case TripStatus.in_progress:
        return Icons.play_arrow;
      case TripStatus.created:
        return Icons.schedule;
      case TripStatus.paused:
        return Icons.pause;
      case TripStatus.finished:
        return Icons.check;
    }
  }

  IconData _getVisibilityIcon(Visibility visibility) {
    switch (visibility) {
      case Visibility.private:
        return Icons.lock;
      case Visibility.protected:
        return Icons.group;
      case Visibility.public:
        return Icons.public;
    }
  }
}
