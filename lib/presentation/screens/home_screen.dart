import 'dart:async';
import 'package:flutter/material.dart' hide Visibility;
import 'package:tracker_frontend/core/constants/enums.dart'
    show TripStatus, Visibility;
import 'package:tracker_frontend/data/models/trip_models.dart';
import 'package:tracker_frontend/data/models/websocket/websocket_event.dart';
import 'package:tracker_frontend/data/repositories/home_repository.dart';
import 'package:tracker_frontend/data/services/trip_service.dart';
import 'package:tracker_frontend/data/services/websocket_service.dart';
import 'package:tracker_frontend/presentation/helpers/dialog_helper.dart';
import 'package:tracker_frontend/presentation/helpers/ui_helpers.dart';
import 'package:tracker_frontend/presentation/helpers/page_transitions.dart';
import 'package:tracker_frontend/presentation/widgets/common/wanderer_app_bar.dart';
import 'package:tracker_frontend/presentation/widgets/common/app_sidebar.dart';
import 'package:tracker_frontend/presentation/widgets/home/enhanced_trip_card.dart';
import 'package:tracker_frontend/presentation/widgets/home/feed_section_header.dart';
import 'package:tracker_frontend/presentation/widgets/home/relationship_badge.dart';
import 'create_trip_screen.dart';
import 'trip_detail_screen.dart';
import 'profile_screen.dart';
import 'auth_screen.dart';

/// Redesigned Home screen with personalized feed, visibility badges, and prioritization
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final HomeRepository _repository = HomeRepository();
  final TripService _tripService = TripService();
  final WebSocketService _webSocketService = WebSocketService();
  final TextEditingController _searchController = TextEditingController();
  StreamSubscription<WebSocketEvent>? _wsSubscription;

  late TabController _tabController;

  List<Trip> _allTrips = [];
  List<Trip> _myTrips = [];
  List<Trip> _feedTrips = [];
  List<Trip> _discoverTrips = [];
  Set<String> _friendIds = {};
  Set<String> _followingIds = {};

  bool _isLoading = false;
  String? _error;
  String? _userId;
  String? _username;
  bool _isLoggedIn = false;
  final int _selectedSidebarIndex = 0;

  // Filter states
  TripStatus? _statusFilter;
  Visibility? _visibilityFilter;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserInfo();
    _loadTrips();
    _searchController.addListener(_applyFilters);
    _initWebSocket();
  }

  Future<void> _initWebSocket() async {
    await _webSocketService.connect();
    _wsSubscription = _webSocketService.events.listen(_handleWebSocketEvent);
  }

  void _handleWebSocketEvent(WebSocketEvent event) {
    if (!mounted) return;

    switch (event.type) {
      case WebSocketEventType.tripStatusChanged:
        _handleTripStatusChanged(event as TripStatusChangedEvent);
        break;
      case WebSocketEventType.tripUpdated:
      case WebSocketEventType.tripCreated:
      case WebSocketEventType.tripDeleted:
        _loadTrips();
        break;
      default:
        break;
    }
  }

  void _handleTripStatusChanged(TripStatusChangedEvent event) {
    final tripIndex = _allTrips.indexWhere((t) => t.id == event.tripId);
    if (tripIndex != -1) {
      setState(() {
        _allTrips[tripIndex] =
            _allTrips[tripIndex].copyWith(status: event.newStatus);
        _categorizeTrips();
      });
    }
  }

  @override
  void dispose() {
    _wsSubscription?.cancel();
    _webSocketService.unsubscribeFromAllTrips();
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserInfo() async {
    final username = await _repository.getCurrentUsername();
    final userId = await _repository.getCurrentUserId();
    final isLoggedIn = await _repository.isLoggedIn();

    setState(() {
      _username = username;
      _userId = userId;
      _isLoggedIn = isLoggedIn;
    });
  }

  Future<void> _loadTrips() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      if (_isLoggedIn) {
        // Load user-specific data
        final results = await Future.wait([
          _repository.loadTrips(), // All available trips
          _repository.getMyTrips(), // User's own trips
          _repository.getFriendsIds(),
          _repository.getFollowingIds(),
        ]);

        setState(() {
          _allTrips = results[0] as List<Trip>;
          _myTrips = results[1] as List<Trip>;
          _friendIds = results[2] as Set<String>;
          _followingIds = results[3] as Set<String>;
          _categorizeTrips();
          _isLoading = false;
        });
      } else {
        // Not logged in, only show public trips
        final trips = await _repository.getPublicTrips();
        setState(() {
          _allTrips = trips;
          _myTrips = [];
          _friendIds = {};
          _followingIds = {};
          _categorizeTrips();
          _isLoading = false;
        });
      }

      // Subscribe to WebSocket updates
      _webSocketService.unsubscribeFromAllTrips();
      _webSocketService.subscribeToTrips(_allTrips.map((t) => t.id).toList());
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _categorizeTrips() {
    if (!_isLoggedIn) {
      _discoverTrips = List.from(_allTrips);
      _feedTrips = [];
      _applyFilters();
      return;
    }

    // Categorize trips for feed
    final feedTrips = <Trip>[];
    final discoverTrips = <Trip>[];

    for (final trip in _allTrips) {
      // Skip user's own trips from feed/discover
      if (trip.userId == _userId) continue;

      final isFriend = _friendIds.contains(trip.userId);
      final isFollowing = _followingIds.contains(trip.userId);
      final isPublic = trip.visibility == Visibility.public;

      // Add to feed if from friend or following
      if (isFriend || isFollowing) {
        // Friends can see PUBLIC and PROTECTED
        if (isFriend && (isPublic || trip.visibility == Visibility.protected)) {
          feedTrips.add(trip);
        }
        // Following can only see PUBLIC
        else if (isFollowing && !isFriend && isPublic) {
          feedTrips.add(trip);
        }
      }

      // Add all public trips to discover
      if (isPublic) {
        discoverTrips.add(trip);
      }
    }

    // Sort feed by priority
    feedTrips.sort(_compareTripsByPriority);

    // Sort discover by date
    discoverTrips.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    setState(() {
      _feedTrips = feedTrips;
      _discoverTrips = discoverTrips;
    });

    _applyFilters();
  }

  /// Compare trips by priority for feed sorting
  int _compareTripsByPriority(Trip a, Trip b) {
    // Priority 1: Live trips (IN_PROGRESS)
    final aIsLive = a.status == TripStatus.inProgress;
    final bIsLive = b.status == TripStatus.inProgress;
    if (aIsLive != bIsLive) return aIsLive ? -1 : 1;

    // Priority 2: Friends over following
    final aIsFriend = _friendIds.contains(a.userId);
    final bIsFriend = _friendIds.contains(b.userId);
    if (aIsFriend != bIsFriend) return aIsFriend ? -1 : 1;

    // Priority 3: Most recent
    return b.createdAt.compareTo(a.createdAt);
  }

  void _applyFilters() {
    setState(() {
      // Filters are applied during rendering in _buildTripList
    });
  }

  List<Trip> _getFilteredTrips(List<Trip> trips) {
    final query = _searchController.text.toLowerCase();
    return trips.where((trip) {
      // Apply search filter
      if (query.isNotEmpty) {
        final matchesQuery = trip.name.toLowerCase().contains(query) ||
            trip.username.toLowerCase().contains(query);
        if (!matchesQuery) return false;
      }

      // Apply status filter
      if (_statusFilter != null && trip.status != _statusFilter) {
        return false;
      }

      // Apply visibility filter
      if (_visibilityFilter != null && trip.visibility != _visibilityFilter) {
        return false;
      }

      return true;
    }).toList();
  }

  void _clearSearch() {
    _searchController.clear();
    _applyFilters();
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

  void _handleProfile() {
    Navigator.push(
      context,
      PageTransitions.slideRight(const ProfileScreen()),
    ).then((result) {
      if (result == true && mounted) {
        _loadUserInfo();
        _loadTrips();
      }
    });
  }

  void _handleSettings() {
    UiHelpers.showSuccessMessage(context, 'User Settings coming soon!');
  }

  Future<void> _navigateToAuth() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AuthScreen()),
    );

    if (result == true && mounted) {
      await _loadUserInfo();
      await _loadTrips();
    }
  }

  Future<void> _navigateToCreateTrip() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateTripScreen()),
    );

    if (mounted) {
      await _loadTrips();
    }
  }

  void _navigateToTripDetail(Trip trip) async {
    await Navigator.push(
      context,
      PageTransitions.slideUp(TripDetailScreen(trip: trip)),
    );

    if (mounted) {
      await _loadTrips();
    }
  }

  Future<void> _handleDeleteTrip(Trip trip) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Trip'),
        content: Text(
          'Are you sure you want to delete "${trip.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    try {
      await _tripService.deleteTrip(trip.id);
      if (mounted) {
        UiHelpers.showSuccessMessage(context, 'Trip deleted');
        await _loadTrips();
      }
    } catch (e) {
      if (mounted) {
        UiHelpers.showErrorMessage(context, 'Error deleting trip: $e');
      }
    }
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Status filters
          _buildFilterChip(
            label: 'All',
            selected: _statusFilter == null,
            onSelected: () => setState(() => _statusFilter = null),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: 'Live',
            icon: Icons.circle,
            iconColor: Colors.green,
            selected: _statusFilter == TripStatus.inProgress,
            onSelected: () =>
                setState(() => _statusFilter = TripStatus.inProgress),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: 'Paused',
            icon: Icons.pause,
            iconColor: Colors.orange,
            selected: _statusFilter == TripStatus.paused,
            onSelected: () => setState(() => _statusFilter = TripStatus.paused),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: 'Completed',
            icon: Icons.check_circle_outline,
            iconColor: Colors.blue,
            selected: _statusFilter == TripStatus.finished,
            onSelected: () =>
                setState(() => _statusFilter = TripStatus.finished),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: 'Draft',
            icon: Icons.edit_outlined,
            iconColor: Colors.grey,
            selected: _statusFilter == TripStatus.created,
            onSelected: () =>
                setState(() => _statusFilter = TripStatus.created),
          ),
          if (_tabController.index == 0) ...[
            const SizedBox(width: 16),
            Container(
              width: 1,
              height: 24,
              color: Colors.grey[300],
            ),
            const SizedBox(width: 16),
            // Visibility filters (only for My Trips tab)
            _buildFilterChip(
              label: 'Public',
              icon: Icons.public,
              iconColor: Colors.green,
              selected: _visibilityFilter == Visibility.public,
              onSelected: () =>
                  setState(() => _visibilityFilter = Visibility.public),
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: 'Protected',
              icon: Icons.lock_outline,
              iconColor: Colors.orange,
              selected: _visibilityFilter == Visibility.protected,
              onSelected: () =>
                  setState(() => _visibilityFilter = Visibility.protected),
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: 'Private',
              icon: Icons.lock,
              iconColor: Colors.red,
              selected: _visibilityFilter == Visibility.private,
              onSelected: () =>
                  setState(() => _visibilityFilter = Visibility.private),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required VoidCallback onSelected,
    IconData? icon,
    Color? iconColor,
  }) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: selected ? Colors.white : iconColor),
            const SizedBox(width: 4),
          ],
          Text(label),
        ],
      ),
      selected: selected,
      onSelected: (_) => onSelected(),
      selectedColor: Theme.of(context).primaryColor,
      labelStyle: TextStyle(
        color: selected ? Colors.white : null,
        fontWeight: selected ? FontWeight.bold : null,
      ),
    );
  }

  Widget _buildMyTripsTab() {
    final filteredTrips = _getFilteredTrips(_myTrips);

    // Group trips by status
    final activeTrips =
        filteredTrips.where((t) => t.status == TripStatus.inProgress).toList();
    final pausedTrips =
        filteredTrips.where((t) => t.status == TripStatus.paused).toList();
    final draftTrips =
        filteredTrips.where((t) => t.status == TripStatus.created).toList();
    final completedTrips =
        filteredTrips.where((t) => t.status == TripStatus.finished).toList();

    if (filteredTrips.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.explore_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No trips yet',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first trip to get started!',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTrips,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (activeTrips.isNotEmpty) ...[
            FeedSectionHeader(
              title: 'Active Trips',
              icon: Icons.location_on,
              count: activeTrips.length,
              subtitle: 'Currently in progress',
            ),
            const SizedBox(height: 12),
            _buildTripGrid(activeTrips, showDelete: true),
            const SizedBox(height: 24),
          ],
          if (pausedTrips.isNotEmpty) ...[
            FeedSectionHeader(
              title: 'Paused Trips',
              icon: Icons.pause_circle_outline,
              count: pausedTrips.length,
              subtitle: 'Temporarily stopped',
            ),
            const SizedBox(height: 12),
            _buildTripGrid(pausedTrips, showDelete: true),
            const SizedBox(height: 24),
          ],
          if (draftTrips.isNotEmpty) ...[
            FeedSectionHeader(
              title: 'Draft Trips',
              icon: Icons.edit_outlined,
              count: draftTrips.length,
              subtitle: 'Not yet started',
            ),
            const SizedBox(height: 12),
            _buildTripGrid(draftTrips, showDelete: true),
            const SizedBox(height: 24),
          ],
          if (completedTrips.isNotEmpty) ...[
            FeedSectionHeader(
              title: 'Completed Trips',
              icon: Icons.check_circle_outline,
              count: completedTrips.length,
              subtitle: 'Finished adventures',
            ),
            const SizedBox(height: 12),
            _buildTripGrid(completedTrips, showDelete: true),
          ],
        ],
      ),
    );
  }

  Widget _buildFeedTab() {
    final filteredTrips = _getFilteredTrips(_feedTrips);

    // Group by live and other
    final liveTrips =
        filteredTrips.where((t) => t.status == TripStatus.inProgress).toList();
    final friendsTrips = filteredTrips
        .where((t) =>
            _friendIds.contains(t.userId) && t.status != TripStatus.inProgress)
        .toList();
    final followingTrips = filteredTrips
        .where((t) =>
            _followingIds.contains(t.userId) &&
            !_friendIds.contains(t.userId) &&
            t.status != TripStatus.inProgress)
        .toList();

    if (filteredTrips.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No trips in your feed',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Follow users or add friends to see their trips!',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTrips,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (liveTrips.isNotEmpty) ...[
            FeedSectionHeader(
              title: 'Live Now',
              icon: Icons.flash_on,
              count: liveTrips.length,
              subtitle: 'Happening right now',
            ),
            const SizedBox(height: 12),
            _buildTripGrid(liveTrips, showRelationship: true),
            const SizedBox(height: 24),
          ],
          if (friendsTrips.isNotEmpty) ...[
            FeedSectionHeader(
              title: 'Friends\' Trips',
              icon: Icons.people,
              count: friendsTrips.length,
              subtitle: 'From your friends',
            ),
            const SizedBox(height: 12),
            _buildTripGrid(friendsTrips,
                showRelationship: true,
                defaultRelationship: RelationshipType.friend),
            const SizedBox(height: 24),
          ],
          if (followingTrips.isNotEmpty) ...[
            FeedSectionHeader(
              title: 'Following',
              icon: Icons.person_add_alt_1,
              count: followingTrips.length,
              subtitle: 'From users you follow',
            ),
            const SizedBox(height: 12),
            _buildTripGrid(followingTrips,
                showRelationship: true,
                defaultRelationship: RelationshipType.following),
          ],
        ],
      ),
    );
  }

  Widget _buildDiscoverTab() {
    final filteredTrips = _getFilteredTrips(_discoverTrips);

    if (filteredTrips.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.explore_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No public trips found',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for new adventures!',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTrips,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FeedSectionHeader(
            title: 'Discover',
            icon: Icons.public,
            count: filteredTrips.length,
            subtitle: 'Explore public trips from the community',
          ),
          const SizedBox(height: 12),
          _buildTripGrid(filteredTrips, showRelationship: true),
        ],
      ),
    );
  }

  Widget _buildTripGrid(
    List<Trip> trips, {
    bool showDelete = false,
    bool showRelationship = false,
    RelationshipType? defaultRelationship,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 1;
        if (constraints.maxWidth > 1200) {
          crossAxisCount = 4;
        } else if (constraints.maxWidth > 800) {
          crossAxisCount = 3;
        } else if (constraints.maxWidth > 600) {
          crossAxisCount = 2;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.75,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: trips.length,
          itemBuilder: (context, index) {
            final trip = trips[index];
            RelationshipType? relationship;

            if (showRelationship && trip.userId != _userId) {
              if (_friendIds.contains(trip.userId)) {
                relationship = RelationshipType.friend;
              } else if (_followingIds.contains(trip.userId)) {
                relationship = RelationshipType.following;
              } else if (defaultRelationship != null) {
                relationship = defaultRelationship;
              }
            }

            return EnhancedTripCard(
              trip: trip,
              onTap: () => _navigateToTripDetail(trip),
              onDelete: showDelete && trip.userId == _userId
                  ? () => _handleDeleteTrip(trip)
                  : null,
              relationship: relationship,
              showAllBadges: true,
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WandererAppBar(
        searchController: _searchController,
        onSearch: _applyFilters,
        onClear: _clearSearch,
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 64, color: Colors.red[300]),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading trips',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadTrips,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : !_isLoggedIn
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.login, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'Welcome to Tracker',
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700]),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Please log in to see personalized content',
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey[500]),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _navigateToAuth,
                            icon: const Icon(Icons.login),
                            label: const Text('Log In'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 16),
                            ),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            'Or explore public trips:',
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 400,
                            child: _buildDiscoverTab(),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        TabBar(
                          controller: _tabController,
                          tabs: const [
                            Tab(
                              icon: Icon(Icons.person),
                              text: 'My Trips',
                            ),
                            Tab(
                              icon: Icon(Icons.dynamic_feed),
                              text: 'Feed',
                            ),
                            Tab(
                              icon: Icon(Icons.explore),
                              text: 'Discover',
                            ),
                          ],
                        ),
                        _buildFilterChips(),
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _buildMyTripsTab(),
                              _buildFeedTab(),
                              _buildDiscoverTab(),
                            ],
                          ),
                        ),
                      ],
                    ),
      floatingActionButton: _username != null
          ? FloatingActionButton.extended(
              onPressed: _navigateToCreateTrip,
              icon: const Icon(Icons.add),
              label: const Text('New Trip'),
            )
          : null,
    );
  }
}
