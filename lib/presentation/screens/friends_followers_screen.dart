import 'package:flutter/material.dart';
import 'package:tracker_frontend/data/models/user_models.dart';
import 'package:tracker_frontend/data/services/user_service.dart';
import 'package:tracker_frontend/presentation/helpers/ui_helpers.dart';
import 'package:tracker_frontend/presentation/widgets/common/wanderer_app_bar.dart';
import 'package:tracker_frontend/presentation/widgets/common/app_sidebar.dart';
import 'auth_screen.dart';

/// Screen for managing friends and followers
class FriendsFollowersScreen extends StatefulWidget {
  const FriendsFollowersScreen({super.key});

  @override
  State<FriendsFollowersScreen> createState() => _FriendsFollowersScreenState();
}

class _FriendsFollowersScreenState extends State<FriendsFollowersScreen>
    with SingleTickerProviderStateMixin {
  final UserService _userService = UserService();
  final TextEditingController _searchController = TextEditingController();

  late TabController _tabController;

  // Data
  List<UserFollow> _followers = [];
  List<UserFollow> _following = [];
  List<Friendship> _friends = [];
  List<FriendRequest> _receivedRequests = [];
  List<FriendRequest> _sentRequests = [];

  // User profiles cache (userId -> UserProfile)
  final Map<String, UserProfile> _userProfiles = {};

  // State
  bool _isLoading = false;
  String? _error;
  UserProfile? _currentUser;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Check if logged in
      final profile = await _userService.getMyProfile();
      setState(() {
        _currentUser = profile;
        _isLoggedIn = true;
      });

      // Load all data in parallel
      final results = await Future.wait([
        _userService.getFollowers(),
        _userService.getFollowing(),
        _userService.getFriends(),
        _userService.getReceivedFriendRequests(),
        _userService.getSentFriendRequests(),
      ]);

      setState(() {
        _followers = results[0] as List<UserFollow>;
        _following = results[1] as List<UserFollow>;
        _friends = results[2] as List<Friendship>;
        _receivedRequests = results[3] as List<FriendRequest>;
        _sentRequests = results[4] as List<FriendRequest>;
        _isLoading = false;
      });

      // Load user profiles for display
      await _loadUserProfiles();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
        _isLoggedIn = false;
      });
    }
  }

  Future<void> _loadUserProfiles() async {
    // Collect all unique user IDs
    final userIds = <String>{};

    for (final follower in _followers) {
      userIds.add(follower.followerId);
    }
    for (final following in _following) {
      userIds.add(following.followedId);
    }
    for (final friend in _friends) {
      userIds.add(friend.friendId);
    }
    for (final request in _receivedRequests) {
      userIds.add(request.senderId);
    }
    for (final request in _sentRequests) {
      userIds.add(request.receiverId);
    }

    // Load profiles in parallel
    try {
      final profiles = await Future.wait(
        userIds.map((id) => _userService.getUserById(id)),
      );

      setState(() {
        for (final profile in profiles) {
          _userProfiles[profile.id] = profile;
        }
      });
    } catch (e) {
      // Silently fail, profiles will show as unknown
    }
  }

  Future<void> _navigateToAuth() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AuthScreen()),
    );

    if (result == true || mounted) {
      await _loadData();
    }
  }

  Future<void> _handleFollowUser(String userId) async {
    try {
      await _userService.followUser(userId);
      if (mounted) {
        UiHelpers.showSuccessMessage(context, 'Follow request sent!');
        await _loadData();
      }
    } catch (e) {
      if (mounted) {
        UiHelpers.showErrorMessage(context, 'Failed to follow user: $e');
      }
    }
  }

  Future<void> _handleUnfollowUser(String userId) async {
    try {
      await _userService.unfollowUser(userId);
      if (mounted) {
        UiHelpers.showSuccessMessage(context, 'Unfollowed user');
        await _loadData();
      }
    } catch (e) {
      if (mounted) {
        UiHelpers.showErrorMessage(context, 'Failed to unfollow user: $e');
      }
    }
  }

  Future<void> _handleSendFriendRequest(String userId) async {
    try {
      await _userService.sendFriendRequest(userId);
      if (mounted) {
        UiHelpers.showSuccessMessage(context, 'Friend request sent!');
        await _loadData();
      }
    } catch (e) {
      if (mounted) {
        UiHelpers.showErrorMessage(context, 'Failed to send friend request: $e');
      }
    }
  }

  Future<void> _handleAcceptFriendRequest(String requestId) async {
    try {
      await _userService.acceptFriendRequest(requestId);
      if (mounted) {
        UiHelpers.showSuccessMessage(context, 'Friend request accepted!');
        await _loadData();
      }
    } catch (e) {
      if (mounted) {
        UiHelpers.showErrorMessage(context, 'Failed to accept friend request: $e');
      }
    }
  }

  Future<void> _handleDeclineFriendRequest(String requestId) async {
    try {
      await _userService.declineFriendRequest(requestId);
      if (mounted) {
        UiHelpers.showSuccessMessage(context, 'Friend request declined');
        await _loadData();
      }
    } catch (e) {
      if (mounted) {
        UiHelpers.showErrorMessage(context, 'Failed to decline friend request: $e');
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
        username: _currentUser?.username,
        userId: _currentUser?.id,
        onProfile: () {},
        onSettings: () {},
        onLogout: () {},
      ),
      drawer: AppSidebar(
        username: _currentUser?.username,
        userId: _currentUser?.id,
        selectedIndex: -1,
        onLogout: () {},
        onSettings: () {},
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
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

    return Column(
      children: [
        Container(
          color: Theme.of(context).primaryColor,
          child: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(
                text: 'Friends (${_friends.length})',
                icon: const Icon(Icons.people),
              ),
              Tab(
                text: 'Followers (${_followers.length})',
                icon: const Icon(Icons.person_add),
              ),
              Tab(
                text: 'Following (${_following.length})',
                icon: const Icon(Icons.person_outline),
              ),
              Tab(
                text: 'Requests (${_receivedRequests.length})',
                icon: const Icon(Icons.notifications),
              ),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildFriendsTab(),
              _buildFollowersTab(),
              _buildFollowingTab(),
              _buildRequestsTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFriendsTab() {
    if (_friends.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No friends yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Send friend requests to connect with others',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _friends.length,
        itemBuilder: (context, index) {
          final friendship = _friends[index];
          final profile = _userProfiles[friendship.friendId];

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: profile?.avatarUrl != null
                    ? NetworkImage(profile!.avatarUrl!)
                    : null,
                child: profile?.avatarUrl == null
                    ? const Icon(Icons.person)
                    : null,
              ),
              title: Text(profile?.username ?? 'Unknown User'),
              subtitle: profile?.displayName != null
                  ? Text(profile!.displayName!)
                  : null,
              trailing: IconButton(
                icon: const Icon(Icons.message),
                onPressed: () {
                  UiHelpers.showSuccessMessage(
                    context,
                    'Messaging coming soon!',
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFollowersTab() {
    if (_followers.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_add_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No followers yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _followers.length,
        itemBuilder: (context, index) {
          final follower = _followers[index];
          final profile = _userProfiles[follower.followerId];

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: profile?.avatarUrl != null
                    ? NetworkImage(profile!.avatarUrl!)
                    : null,
                child: profile?.avatarUrl == null
                    ? const Icon(Icons.person)
                    : null,
              ),
              title: Text(profile?.username ?? 'Unknown User'),
              subtitle: profile?.displayName != null
                  ? Text(profile!.displayName!)
                  : null,
              trailing: ElevatedButton(
                onPressed: () =>
                    _handleFollowUser(follower.followerId),
                child: const Text('Follow Back'),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFollowingTab() {
    if (_following.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Not following anyone yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _following.length,
        itemBuilder: (context, index) {
          final following = _following[index];
          final profile = _userProfiles[following.followedId];

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: profile?.avatarUrl != null
                    ? NetworkImage(profile!.avatarUrl!)
                    : null,
                child: profile?.avatarUrl == null
                    ? const Icon(Icons.person)
                    : null,
              ),
              title: Text(profile?.username ?? 'Unknown User'),
              subtitle: profile?.displayName != null
                  ? Text(profile!.displayName!)
                  : null,
              trailing: ElevatedButton(
                onPressed: () =>
                    _handleUnfollowUser(following.followedId),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                ),
                child: const Text('Unfollow'),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRequestsTab() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            labelColor: Colors.black,
            tabs: [
              Tab(text: 'Received'),
              Tab(text: 'Sent'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildReceivedRequestsView(),
                _buildSentRequestsView(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceivedRequestsView() {
    if (_receivedRequests.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No friend requests',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _receivedRequests.length,
        itemBuilder: (context, index) {
          final request = _receivedRequests[index];
          final profile = _userProfiles[request.senderId];

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: profile?.avatarUrl != null
                    ? NetworkImage(profile!.avatarUrl!)
                    : null,
                child: profile?.avatarUrl == null
                    ? const Icon(Icons.person)
                    : null,
              ),
              title: Text(profile?.username ?? 'Unknown User'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (profile?.displayName != null)
                    Text(profile!.displayName!),
                  Text(
                    'Sent ${_formatDate(request.createdAt)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: () => _handleAcceptFriendRequest(request.id),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () => _handleDeclineFriendRequest(request.id),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSentRequestsView() {
    if (_sentRequests.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.send_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No sent requests',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _sentRequests.length,
        itemBuilder: (context, index) {
          final request = _sentRequests[index];
          final profile = _userProfiles[request.receiverId];

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: profile?.avatarUrl != null
                    ? NetworkImage(profile!.avatarUrl!)
                    : null,
                child: profile?.avatarUrl == null
                    ? const Icon(Icons.person)
                    : null,
              ),
              title: Text(profile?.username ?? 'Unknown User'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (profile?.displayName != null)
                    Text(profile!.displayName!),
                  Text(
                    'Sent ${_formatDate(request.createdAt)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              trailing: Chip(
                label: Text(request.status.toJson()),
                backgroundColor: _getStatusColor(request.status),
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'just now';
    }
  }

  Color _getStatusColor(FriendRequestStatus status) {
    switch (status) {
      case FriendRequestStatus.pending:
        return Colors.orange.withOpacity(0.3);
      case FriendRequestStatus.accepted:
        return Colors.green.withOpacity(0.3);
      case FriendRequestStatus.declined:
        return Colors.red.withOpacity(0.3);
    }
  }
}
