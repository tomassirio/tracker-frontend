import 'package:flutter/material.dart';
import 'package:tracker_frontend/data/models/trip_models.dart';
import 'package:tracker_frontend/data/models/user_models.dart';
import 'package:tracker_frontend/data/repositories/profile_repository.dart';
import 'package:tracker_frontend/data/services/user_service.dart';
import 'package:tracker_frontend/presentation/helpers/dialog_helper.dart';
import 'package:tracker_frontend/presentation/helpers/ui_helpers.dart';
import 'package:tracker_frontend/presentation/helpers/page_transitions.dart';
import 'package:tracker_frontend/presentation/widgets/common/wanderer_app_bar.dart';
import 'package:tracker_frontend/presentation/widgets/common/app_sidebar.dart';
import 'package:tracker_frontend/core/constants/api_endpoints.dart';
import '../../core/constants/enums.dart';
import '../../data/client/google_maps_api_client.dart';
import '../../data/client/google_routes_api_client.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'auth_screen.dart';
import 'trip_detail_screen.dart';
import 'friends_followers_screen.dart';

/// User profile screen showing user information, statistics, and trips
class ProfileScreen extends StatefulWidget {
  final String? userId;

  const ProfileScreen({super.key, this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileRepository _repository = ProfileRepository();
  final UserService _userService = UserService();
  final TextEditingController _searchController = TextEditingController();
  UserProfile? _profile;
  List<Trip> _userTrips = [];
  bool _isLoadingProfile = false;
  bool _isLoadingTrips = false;
  String? _error;
  bool _isLoggedIn = false;
  bool _hasSentFriendRequest =
      false; // Track if friend request was sent locally
  bool _isAlreadyFriends = false; // Track if already friends with user
  String? _sentFriendRequestId; // Store the request ID for cancellation
  final int _selectedSidebarIndex = 4; // Profile is index 4

  // Actual counts loaded from API (for own profile)
  int _followersCount = 0;
  int _followingCount = 0;
  int _friendsCount = 0;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoadingProfile = true;
      _error = null;
    });

    try {
      final isLoggedIn = await _repository.isLoggedIn();
      setState(() {
        _isLoggedIn = isLoggedIn;
      });

      // Load current user if logged in
      if (isLoggedIn) {
        try {
          await _repository.getMyProfile();
          // Load social counts for own profile
          await _loadSocialCounts();
        } catch (e) {
          // Ignore error loading current user
        }
      }

      // If viewing another user's profile
      if (widget.userId != null) {
        final profile = await _repository.getUserProfile(widget.userId!);
        setState(() {
          _profile = profile;
          _followersCount = profile.followersCount;
          _followingCount = profile.followingCount;
          _isLoadingProfile = false;
        });

        // Load user's trips and check friendship status
        _loadUserTrips(profile.id);
        if (isLoggedIn) {
          await _loadFriendshipStatus(profile.id);
        }
        return;
      }

      // Viewing own profile
      if (!isLoggedIn) {
        setState(() {
          _isLoadingProfile = false;
          _error = 'You must be logged in to view your profile';
        });
        return;
      }

      final profile = await _repository.getMyProfile();
      setState(() {
        _profile = profile;
        _isLoadingProfile = false;
      });

      // Load user's trips and social counts
      _loadUserTrips(profile.id);
      await _loadSocialCounts();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoadingProfile = false;
      });
    }
  }

  /// Load follower, following, and friends counts from API
  Future<void> _loadSocialCounts() async {
    try {
      final results = await Future.wait([
        _userService.getFollowers(),
        _userService.getFollowing(),
        _userService.getFriends(),
      ]);

      if (mounted) {
        setState(() {
          _followersCount = (results[0] as List).length;
          _followingCount = (results[1] as List).length;
          _friendsCount = (results[2] as List).length;
        });
      }
    } catch (e) {
      // Silently fail - use profile counts as fallback
      debugPrint('Failed to load social counts: $e');
    }
  }

  /// Load friendship status when viewing another user's profile
  Future<void> _loadFriendshipStatus(String userId) async {
    try {
      // Check if already friends
      final friends = await _userService.getFriends();
      final isAlreadyFriends = friends.any((f) => f.friendId == userId);

      // Check if already sent a friend request
      final sentRequests = await _userService.getSentFriendRequests();
      final pendingRequest = sentRequests.cast<FriendRequest?>().firstWhere(
            (r) =>
                r!.receiverId == userId &&
                r.status == FriendRequestStatus.pending,
            orElse: () => null,
          );
      final hasSentRequest = pendingRequest != null;
      final requestId = pendingRequest?.id;

      if (mounted) {
        setState(() {
          _isAlreadyFriends = isAlreadyFriends;
          _hasSentFriendRequest = hasSentRequest;
          _sentFriendRequestId = requestId;
        });
      }
    } catch (e) {
      // Silently fail - friendship features are optional
      debugPrint('Failed to load friendship status: $e');
    }
  }

  Future<void> _loadUserTrips(String userId) async {
    setState(() {
      _isLoadingTrips = true;
    });

    try {
      final trips = await _repository.getUserTrips(userId);
      setState(() {
        _userTrips = trips;
        _isLoadingTrips = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingTrips = false;
      });
      if (mounted) {
        UiHelpers.showErrorMessage(context, 'Failed to load trips: $e');
      }
    }
  }

  Future<void> _logout() async {
    final confirm = await DialogHelper.showLogoutConfirmation(context);

    if (confirm) {
      await _repository.logout();
      if (mounted) {
        Navigator.of(context).pop(true); // Return to previous screen
      }
    }
  }

  void _handleSettings() {
    UiHelpers.showSuccessMessage(context, 'User Settings coming soon!');
  }

  Future<void> _navigateToAuth() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AuthScreen()),
    );

    if (result == true || mounted) {
      await _loadProfile();
    }
  }

  void _navigateToTripDetail(Trip trip) {
    Navigator.push(
      context,
      PageTransitions.slideUp(TripDetailScreen(trip: trip)),
    );
  }

  void _navigateToFriendsFollowers() {
    Navigator.push(
      context,
      PageTransitions.slideUp(const FriendsFollowersScreen()),
    );
  }

  Future<void> _showEditProfileDialog() async {
    if (_profile == null) return;

    final displayNameController = TextEditingController(
      text: _profile!.displayName,
    );
    final bioController = TextEditingController(text: _profile!.bio);
    final avatarUrlController = TextEditingController(
      text: _profile!.avatarUrl,
    );

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: displayNameController,
                decoration: const InputDecoration(
                  labelText: 'Display Name',
                  hintText: 'Your display name',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: bioController,
                decoration: const InputDecoration(
                  labelText: 'Bio',
                  hintText: 'Tell us about yourself',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: avatarUrlController,
                decoration: const InputDecoration(
                  labelText: 'Avatar URL',
                  hintText: 'https://example.com/avatar.jpg',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == true) {
      await _updateProfile(
        displayNameController.text,
        bioController.text,
        avatarUrlController.text,
      );
    }

    displayNameController.dispose();
    bioController.dispose();
    avatarUrlController.dispose();
  }

  Future<void> _handleFollowUser() async {
    if (_profile == null) return;

    try {
      await _userService.followUser(_profile!.id);
      if (mounted) {
        UiHelpers.showSuccessMessage(
            context, 'You are now following ${_profile!.username}');
        // Reload profile to get updated isFollowing status
        await _loadProfile();
      }
    } catch (e) {
      if (mounted) {
        UiHelpers.showErrorMessage(context, 'Failed to follow user: $e');
      }
    }
  }

  Future<void> _handleUnfollowUser() async {
    if (_profile == null) return;

    try {
      await _userService.unfollowUser(_profile!.id);
      if (mounted) {
        UiHelpers.showSuccessMessage(
            context, 'Unfollowed ${_profile!.username}');
        // Reload profile to get updated isFollowing status
        await _loadProfile();
      }
    } catch (e) {
      if (mounted) {
        UiHelpers.showErrorMessage(context, 'Failed to unfollow user: $e');
      }
    }
  }

  Future<void> _handleSendFriendRequest() async {
    if (_profile == null) return;

    // If already friends, allow unfriending
    if (_isAlreadyFriends) {
      try {
        await _userService.removeFriend(_profile!.id);
        setState(() {
          _isAlreadyFriends = false;
        });
        if (mounted) {
          UiHelpers.showSuccessMessage(
              context, 'You are no longer friends with ${_profile!.username}');
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
      final requestId = await _userService.sendFriendRequest(_profile!.id);
      setState(() {
        _hasSentFriendRequest = true;
        _sentFriendRequestId = requestId;
      });
      if (mounted) {
        UiHelpers.showSuccessMessage(
            context, 'Friend request sent to ${_profile!.username}');
      }
    } catch (e) {
      if (mounted) {
        UiHelpers.showErrorMessage(
            context, 'Failed to send friend request: $e');
      }
    }
  }

  Future<void> _updateProfile(
    String displayName,
    String bio,
    String avatarUrl,
  ) async {
    try {
      final request = UpdateProfileRequest(
        displayName: displayName.isEmpty ? null : displayName,
        bio: bio.isEmpty ? null : bio,
        avatarUrl: avatarUrl.isEmpty ? null : avatarUrl,
      );

      final updatedProfile = await _repository.updateProfile(request);
      setState(() {
        _profile = updatedProfile;
      });

      if (mounted) {
        UiHelpers.showSuccessMessage(context, 'Profile updated successfully!');
      }
    } catch (e) {
      if (mounted) {
        UiHelpers.showErrorMessage(context, 'Failed to update profile: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WandererAppBar(
        searchController: _searchController,
        onSearch: () {},
        onClear: () {},
        isLoggedIn: _isLoggedIn,
        onLoginPressed: _navigateToAuth,
        username: _profile?.username,
        userId: _profile?.id,
        onProfile: () {},
        onSettings: _handleSettings,
        onLogout: _logout,
      ),
      drawer: AppSidebar(
        username: _profile?.username,
        userId: _profile?.id,
        selectedIndex: _selectedSidebarIndex,
        onLogout: _logout,
        onSettings: _handleSettings,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoadingProfile) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            if (!_isLoggedIn) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _navigateToAuth,
                child: const Text('Login'),
              ),
            ],
          ],
        ),
      );
    }

    if (_profile == null) {
      return const Center(child: Text('No profile data available'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 24),
          _buildStatsRow(),
          const SizedBox(height: 24),
          _buildTripsSection(),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: _profile!.avatarUrl != null
                      ? NetworkImage(_profile!.avatarUrl!)
                      : null,
                  child: _profile!.avatarUrl == null
                      ? Text(
                          _profile!.username.substring(0, 1).toUpperCase(),
                          style: const TextStyle(fontSize: 32),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              _profile!.displayName ?? _profile!.username,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (_profile!.isFollowing) ...[
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.person_add_alt_1,
                              size: 20,
                              color: Colors.blue,
                            ),
                          ],
                        ],
                      ),
                      Text(
                        '@${_profile!.username}',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _profile!.email,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                if (widget.userId == null)
                  // Only show edit button for own profile
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: _showEditProfileDialog,
                    tooltip: 'Edit Profile',
                  )
                else
                  // Show follow/friend request buttons for other users
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          _profile!.isFollowing
                              ? Icons.person_remove
                              : Icons.person_add,
                        ),
                        onPressed: _profile!.isFollowing
                            ? _handleUnfollowUser
                            : _handleFollowUser,
                        tooltip: _profile!.isFollowing ? 'Unfollow' : 'Follow',
                        color: _profile!.isFollowing ? Colors.blue : null,
                      ),
                      IconButton(
                        icon: Icon(
                          _isAlreadyFriends
                              ? Icons.people
                              : _hasSentFriendRequest
                                  ? Icons.person_add_disabled
                                  : Icons.person_add_alt,
                        ),
                        onPressed: _handleSendFriendRequest,
                        tooltip: _isAlreadyFriends
                            ? 'Unfriend'
                            : _hasSentFriendRequest
                                ? 'Cancel Friend Request'
                                : 'Send Friend Request',
                        color: _isAlreadyFriends
                            ? Colors.green
                            : _hasSentFriendRequest
                                ? Colors.orange
                                : null,
                      ),
                    ],
                  ),
              ],
            ),
            if (_profile!.bio != null) ...[
              const SizedBox(height: 16),
              Text(_profile!.bio!, style: const TextStyle(fontSize: 16)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatCard('Trips', _userTrips.length.toString(), null),
        _buildStatCard('Followers', _followersCount.toString(),
            _navigateToFriendsFollowers),
        _buildStatCard('Following', _followingCount.toString(),
            _navigateToFriendsFollowers),
        _buildStatCard(
            'Friends', _friendsCount.toString(), _navigateToFriendsFollowers),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, VoidCallback? onTap) {
    final card = Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );

    return Expanded(
      child: onTap != null
          ? InkWell(
              onTap: onTap,
              child: card,
            )
          : card,
    );
  }

  Widget _buildTripsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'My Trips',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            if (_userTrips.isNotEmpty)
              Text(
                '${_userTrips.length} ${_userTrips.length == 1 ? 'trip' : 'trips'}',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (_isLoadingTrips)
          const Center(child: CircularProgressIndicator())
        else if (_userTrips.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text('No trips yet'),
            ),
          )
        else
          // Make the trip list independently scrollable with a max height
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxHeight: 500, // Maximum height before scrolling kicks in
            ),
            child: ListView.builder(
              shrinkWrap: false,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: _userTrips.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildTripCard(_userTrips[index]),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildTripCard(Trip trip) {
    return ProfileTripCard(
      trip: trip,
      onTap: () => _navigateToTripDetail(trip),
    );
  }
}

/// Trip card for profile screen with mini map
class ProfileTripCard extends StatefulWidget {
  final Trip trip;
  final VoidCallback onTap;

  const ProfileTripCard({super.key, required this.trip, required this.onTap});

  @override
  State<ProfileTripCard> createState() => _ProfileTripCardState();
}

class _ProfileTripCardState extends State<ProfileTripCard> {
  String? _encodedPolyline;
  late final GoogleMapsApiClient _mapsClient;
  late final GoogleRoutesApiClient _routesClient;

  @override
  void initState() {
    super.initState();
    final apiKey = ApiEndpoints.googleMapsApiKey;
    _mapsClient = GoogleMapsApiClient(apiKey);
    _routesClient = GoogleRoutesApiClient(apiKey);
    _fetchRoute();
  }

  /// Fetch the walking route between first and last location
  Future<void> _fetchRoute() async {
    if (widget.trip.locations == null || widget.trip.locations!.length < 2) {
      return;
    }

    try {
      // Get route between first and last location
      final firstLocation = widget.trip.locations!.first;
      final lastLocation = widget.trip.locations!.last;

      final waypoints = [
        LatLng(firstLocation.latitude, firstLocation.longitude),
        LatLng(lastLocation.latitude, lastLocation.longitude),
      ];

      final result = await _routesClient.getWalkingRoute(waypoints);

      if (result.isSuccess && mounted) {
        // Encode the route points to use in Static Maps API
        final encoded = GoogleRoutesApiClient.encodePolyline(result.points);
        setState(() {
          _encodedPolyline = encoded;
        });
      }
    } catch (e) {
      debugPrint('Failed to fetch route for profile trip card: $e');
    }
  }

  /// Generate static map image URL from Google Maps Static API
  String _generateStaticMapUrl() {
    if (widget.trip.locations == null || widget.trip.locations!.isEmpty) {
      return '';
    }

    final firstLoc = widget.trip.locations!.first;
    final lastLoc = widget.trip.locations!.last;

    if (widget.trip.locations!.length == 1) {
      // Single location
      return _mapsClient.generateStaticMapUrl(
        center: LatLng(firstLoc.latitude, firstLoc.longitude),
        markers: [
          MapMarker(
            position: LatLng(firstLoc.latitude, firstLoc.longitude),
            color: 'green',
          ),
        ],
        size: GoogleMapsApiClient.defaultSquareSize,
      );
    } else {
      // Multiple locations - show route
      return _mapsClient.generateRouteMapUrl(
        startPoint: LatLng(firstLoc.latitude, firstLoc.longitude),
        endPoint: LatLng(lastLoc.latitude, lastLoc.longitude),
        encodedPolyline: _encodedPolyline,
        size: GoogleMapsApiClient.defaultSquareSize,
      );
    }
  }

  Color _getStatusColor(TripStatus status) {
    switch (status) {
      case TripStatus.created:
        return Colors.grey;
      case TripStatus.inProgress:
        return Colors.blue;
      case TripStatus.paused:
        return Colors.orange;
      case TripStatus.finished:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: widget.onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mini map preview (120x120)
            SizedBox(width: 120, height: 120, child: _buildMiniMap()),
            // Trip info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Trip title
                    Text(
                      widget.trip.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(widget.trip.status),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        widget.trip.status
                            .toString()
                            .split('.')
                            .last
                            .toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Metadata
                    Row(
                      children: [
                        Icon(Icons.comment, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.trip.commentsCount}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          widget.trip.visibility.toJson() == 'PUBLIC'
                              ? Icons.public
                              : Icons.lock,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.trip.visibility.toJson(),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniMap() {
    if (widget.trip.locations == null || widget.trip.locations!.isEmpty) {
      return Container(
        color: Colors.grey[300],
        child: Center(
          child: Icon(Icons.map_outlined, size: 32, color: Colors.grey[500]),
        ),
      );
    }

    return Image.network(
      _generateStaticMapUrl(),
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: Colors.grey[300],
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              strokeWidth: 2,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[300],
          child: Center(
            child: Icon(Icons.map, size: 32, color: Colors.grey[500]),
          ),
        );
      },
    );
  }
}
