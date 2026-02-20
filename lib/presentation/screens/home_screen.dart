import 'dart:async';
import 'package:flutter/material.dart' hide Visibility;
import 'package:tracker_frontend/core/constants/enums.dart'
    show TripStatus, Visibility;
import 'package:tracker_frontend/data/client/api_client.dart';
import 'package:tracker_frontend/data/models/trip_models.dart';
import 'package:tracker_frontend/data/models/websocket/websocket_event.dart';
import 'package:tracker_frontend/data/repositories/home_repository.dart';
import 'package:tracker_frontend/data/services/trip_service.dart';
import 'package:tracker_frontend/data/services/websocket_service.dart';
import 'package:tracker_frontend/presentation/helpers/dialog_helper.dart';
import 'package:tracker_frontend/presentation/helpers/ui_helpers.dart';
import 'package:tracker_frontend/presentation/helpers/page_transitions.dart';
import 'package:tracker_frontend/presentation/helpers/auth_navigation_helper.dart';
import 'package:tracker_frontend/presentation/widgets/common/wanderer_app_bar.dart';
import 'package:tracker_frontend/presentation/widgets/common/app_sidebar.dart';
import 'package:tracker_frontend/presentation/widgets/home/enhanced_trip_card.dart';
import 'package:tracker_frontend/presentation/widgets/home/feed_section_header.dart';
import 'package:tracker_frontend/presentation/widgets/home/relationship_badge.dart';
import 'package:tracker_frontend/main.dart' show routeObserver;
import 'create_trip_screen.dart';
import 'trip_detail_screen.dart';
import 'auth_screen.dart';

/// Redesigned Home screen with personalized feed, visibility badges, and prioritization
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin, RouteAware {
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
    _tabController.addListener(_onTabChanged);
    _initializeData();
    _searchController.addListener(_applyFilters);
    _initWebSocket();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void didPopNext() {
    // Called when a route that was pushed on top of this one is popped.
    // Reload data in case the user logged in or out while on another screen.
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadUserInfo();
    await _loadTrips();
  }

  void _onTabChanged() {
    // Rebuild to update the filter chips visibility based on selected tab
    if (mounted) {
      setState(() {
        // Reset visibility filter when switching away from My Trips tab
        // since visibility filter only applies to My Trips
        if (_tabController.index != 0) {
          _visibilityFilter = null;
        }
      });
    }
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
    routeObserver.unsubscribe(this);
    _wsSubscription?.cancel();
    _webSocketService.unsubscribeFromAllTrips();
    _searchController.dispose();
    _tabController.removeListener(_onTabChanged);
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
    } on AuthenticationRedirectException {
      // Token expired or user not authenticated - treat as guest
      if (mounted) {
        setState(() {
          _isLoggedIn = false;
          _isLoading = false;
        });
        _loadTrips(); // Reload as guest
      }
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
    AuthNavigationHelper.navigateToOwnProfile(context);
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
      ),
      child: Row(
        children: [
          const Spacer(), // Push dropdowns to the right
          // Status filter dropdown
          PopupMenuButton<TripStatus?>(
            onSelected: (value) {
              setState(() => _statusFilter = value);
            },
            itemBuilder: (context) => [
              PopupMenuItem<TripStatus?>(
                value: null,
                onTap: () {
                  // Handle null selection explicitly
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() => _statusFilter = null);
                  });
                },
                child: Row(
                  children: [
                    Icon(Icons.all_inclusive, size: 18),
                    SizedBox(width: 8),
                    Text('All Status'),
                  ],
                ),
              ),
              PopupMenuItem<TripStatus?>(
                value: TripStatus.inProgress,
                child: Row(
                  children: [
                    Icon(Icons.circle, size: 18, color: Colors.green),
                    const SizedBox(width: 8),
                    const Text('Live'),
                  ],
                ),
              ),
              PopupMenuItem<TripStatus?>(
                value: TripStatus.paused,
                child: Row(
                  children: [
                    Icon(Icons.pause, size: 18, color: Colors.orange),
                    const SizedBox(width: 8),
                    const Text('Paused'),
                  ],
                ),
              ),
              PopupMenuItem<TripStatus?>(
                value: TripStatus.finished,
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline,
                        size: 18, color: Colors.blue),
                    const SizedBox(width: 8),
                    const Text('Completed'),
                  ],
                ),
              ),
              PopupMenuItem<TripStatus?>(
                value: TripStatus.created,
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 18, color: Colors.grey),
                    const SizedBox(width: 8),
                    const Text('Draft'),
                  ],
                ),
              ),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getStatusIcon(_statusFilter),
                    size: 18,
                    color: _getStatusColor(_statusFilter),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _statusFilter == null
                        ? 'All Status'
                        : _getStatusLabel(_statusFilter!),
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_drop_down, size: 20),
                ],
              ),
            ),
          ),
          // Only show visibility filter on My Trips tab
          if (_tabController.index == 0) ...[
            const SizedBox(width: 12),
            PopupMenuButton<Visibility?>(
              onSelected: (value) {
                setState(() => _visibilityFilter = value);
              },
              itemBuilder: (context) => [
                PopupMenuItem<Visibility?>(
                  value: null,
                  onTap: () {
                    // Handle null selection explicitly
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      setState(() => _visibilityFilter = null);
                    });
                  },
                  child: Row(
                    children: [
                      Icon(Icons.all_inclusive, size: 18),
                      SizedBox(width: 8),
                      Text('All Visibility'),
                    ],
                  ),
                ),
                PopupMenuItem<Visibility?>(
                  value: Visibility.public,
                  child: Row(
                    children: [
                      Icon(Icons.public, size: 18, color: Colors.green),
                      const SizedBox(width: 8),
                      const Text('Public'),
                    ],
                  ),
                ),
                PopupMenuItem<Visibility?>(
                  value: Visibility.protected,
                  child: Row(
                    children: [
                      Icon(Icons.lock_outline, size: 18, color: Colors.orange),
                      const SizedBox(width: 8),
                      const Text('Protected'),
                    ],
                  ),
                ),
                PopupMenuItem<Visibility?>(
                  value: Visibility.private,
                  child: Row(
                    children: [
                      Icon(Icons.lock, size: 18, color: Colors.red),
                      const SizedBox(width: 8),
                      const Text('Private'),
                    ],
                  ),
                ),
              ],
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getVisibilityIcon(_visibilityFilter),
                      size: 18,
                      color: _getVisibilityColor(_visibilityFilter),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _visibilityFilter == null
                          ? 'All Visibility'
                          : _getVisibilityLabel(_visibilityFilter!),
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_drop_down, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getStatusIcon(TripStatus? status) {
    if (status == null) return Icons.all_inclusive;
    switch (status) {
      case TripStatus.inProgress:
        return Icons.circle;
      case TripStatus.paused:
        return Icons.pause;
      case TripStatus.finished:
        return Icons.check_circle_outline;
      case TripStatus.created:
        return Icons.edit_outlined;
    }
  }

  Color _getStatusColor(TripStatus? status) {
    if (status == null) return Colors.grey;
    switch (status) {
      case TripStatus.inProgress:
        return Colors.green;
      case TripStatus.paused:
        return Colors.orange;
      case TripStatus.finished:
        return Colors.blue;
      case TripStatus.created:
        return Colors.grey;
    }
  }

  String _getStatusLabel(TripStatus status) {
    switch (status) {
      case TripStatus.inProgress:
        return 'Live';
      case TripStatus.paused:
        return 'Paused';
      case TripStatus.finished:
        return 'Completed';
      case TripStatus.created:
        return 'Draft';
    }
  }

  IconData _getVisibilityIcon(Visibility? visibility) {
    if (visibility == null) return Icons.all_inclusive;
    switch (visibility) {
      case Visibility.public:
        return Icons.public;
      case Visibility.protected:
        return Icons.lock_outline;
      case Visibility.private:
        return Icons.lock;
    }
  }

  Color _getVisibilityColor(Visibility? visibility) {
    if (visibility == null) return Colors.grey;
    switch (visibility) {
      case Visibility.public:
        return Colors.green;
      case Visibility.protected:
        return Colors.orange;
      case Visibility.private:
        return Colors.red;
    }
  }

  String _getVisibilityLabel(Visibility visibility) {
    switch (visibility) {
      case Visibility.public:
        return 'Public';
      case Visibility.protected:
        return 'Protected';
      case Visibility.private:
        return 'Private';
    }
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

  // Build discover section for guest users without ListView wrapper
  Widget _buildGuestDiscoverSection() {
    final filteredTrips = _getFilteredTrips(_discoverTrips);

    if (filteredTrips.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
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
        ),
      );
    }

    return _buildTripGrid(filteredTrips, showRelationship: false);
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

        // Adjust aspect ratio based on column count for better responsiveness
        final double childAspectRatio;
        if (crossAxisCount == 1) {
          childAspectRatio = 1.3; // Wider cards on mobile to avoid stretching
        } else if (crossAxisCount == 2) {
          childAspectRatio = 0.85;
        } else {
          childAspectRatio = 0.9;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
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
                  ? SingleChildScrollView(
                      child: Column(
                        children: [
                          // Hero section with better visuals
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                vertical: 48, horizontal: 24),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.1),
                                  Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.05),
                                ],
                              ),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: ClipOval(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Image.network(
                                        'icons/Icon-192.png',
                                        fit: BoxFit.contain,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Icon(
                                            Icons.explore,
                                            size: 64,
                                            color:
                                                Theme.of(context).primaryColor,
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                const Text(
                                  'Welcome to Wanderer',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -1,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Track your adventures, share your journeys',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 32),
                                ElevatedButton(
                                  onPressed: _navigateToAuth,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 40,
                                      vertical: 16,
                                    ),
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'Log In',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Discover section with better header
                          Container(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .primaryColor
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.public,
                                        color: Theme.of(context).primaryColor,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Explore Public Trips',
                                            style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: -0.5,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Discover adventures from the community',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                // Build trip grid directly for guest users (no ListView wrapper)
                                _buildGuestDiscoverSection(),
                              ],
                            ),
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
