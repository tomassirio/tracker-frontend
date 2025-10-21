import 'package:flutter/material.dart';
import 'package:tracker_frontend/data/models/trip_models.dart';
import 'package:tracker_frontend/data/services/trip_service.dart';
import 'package:tracker_frontend/data/services/auth_service.dart';
import 'create_trip_screen.dart';
import 'trip_detail_screen.dart';
import 'auth_screen.dart';

/// Home screen showing list of trips
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TripService _tripService = TripService();
  final AuthService _authService = AuthService();
  List<Trip> _trips = [];
  bool _isLoading = false;
  String? _error;
  String? _userId;
  String? _username;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadTrips();
  }

  Future<void> _loadUserInfo() async {
    final username = await _authService.getCurrentUsername();
    final userId = await _authService.getCurrentUserId();
    final isLoggedIn = await _authService.isLoggedIn();

    print(
        'Loading user info - username: $username, userId: $userId, isLoggedIn: $isLoggedIn');

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
      // Check if user is logged in and get userId directly
      final isLoggedIn = await _authService.isLoggedIn();
      final userId = await _authService.getCurrentUserId();

      // Load public trips if not logged in, or user's trips if logged in
      final trips = isLoggedIn && userId != null
          ? await _tripService.getAvailableTrips()
          : await _tripService.getPublicTrips();

      setState(() {
        _trips = trips;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _authService.logout();
      if (mounted) {
        // Reload user info and trips (will show public trips now)
        await _loadUserInfo();
        await _loadTrips();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLoggedIn ? 'My Trips' : 'Public Trips'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_username != null)
            // Show profile menu for authenticated users
            PopupMenuButton<String>(
              icon: const Icon(Icons.account_circle),
              tooltip: 'Profile',
              onSelected: (value) {
                if (value == 'logout') {
                  _logout();
                } else if (value == 'profile') {
                  // Navigate to user profile screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('User Profile coming soon!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem<String>(
                  enabled: false,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              child: Text(
                                _username![0].toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _username!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  if (_userId != null)
                                    Text(
                                      'ID: ${_userId!.substring(0, 8)}...',
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
                        const Divider(),
                      ],
                    ),
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'profile',
                  child: Row(
                    children: [
                      Icon(Icons.person),
                      SizedBox(width: 12),
                      Text('User Profile'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.red),
                      SizedBox(width: 12),
                      Text('Logout', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            )
          else
            // Show login button for non-authenticated users
            TextButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AuthScreen(),
                  ),
                );
                // Reload data if user logged in
                if (result == true) {
                  await _loadUserInfo();
                  await _loadTrips();
                } else if (mounted) {
                  // Even if result is not true, check if user is logged in
                  await _loadUserInfo();
                  await _loadTrips();
                }
              },
              icon: const Icon(Icons.login, color: Colors.white),
              label: const Text(
                'Login',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: _username != null
          ? FloatingActionButton.extended(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateTripScreen(),
                  ),
                );
                if (result == true) {
                  _loadTrips();
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Trip'),
            )
          : null,
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
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading trips',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadTrips,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_trips.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isLoggedIn ? Icons.explore_off : Icons.public_off,
              size: 100,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _isLoggedIn ? 'No trips yet' : 'No public trips available',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _isLoggedIn
                  ? 'Create your first trip to get started!'
                  : 'Check back later or login to create your own trips',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (!_isLoggedIn) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AuthScreen(),
                    ),
                  );
                  if (result == true || mounted) {
                    _loadUserInfo();
                    _loadTrips();
                  }
                },
                icon: const Icon(Icons.login),
                label: const Text('Login / Register'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTrips,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _trips.length,
        itemBuilder: (context, index) {
          final trip = _trips[index];
          return _buildTripCard(trip);
        },
      ),
    );
  }

  Card _buildTripCard(Trip trip) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(trip.status),
          child: Icon(
            _getStatusIcon(trip.status),
            color: Colors.white,
          ),
        ),
        title: Text(
          trip.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (trip.description != null) ...[
              const SizedBox(height: 4),
              Text(
                trip.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                Chip(
                  label: Text(
                    trip.status.toJson(),
                    style: const TextStyle(fontSize: 11),
                  ),
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(
                    trip.visibility.toJson(),
                    style: const TextStyle(fontSize: 11),
                  ),
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TripDetailScreen(trip: trip),
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(status) {
    switch (status.toString()) {
      case 'TripStatus.in_progress':
        return Colors.green;
      case 'TripStatus.created':
        return Colors.blue;
      case 'TripStatus.paused':
        return Colors.orange;
      case 'TripStatus.finished':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(status) {
    switch (status.toString()) {
      case 'TripStatus.in_progress':
        return Icons.play_arrow;
      case 'TripStatus.created':
        return Icons.schedule;
      case 'TripStatus.paused':
        return Icons.pause;
      case 'TripStatus.finished':
        return Icons.check;
      default:
        return Icons.help;
    }
  }
}
