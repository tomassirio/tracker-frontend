import 'package:flutter/material.dart';
import 'package:tracker_frontend/data/models/trip_models.dart';
import 'package:tracker_frontend/data/repositories/home_repository.dart';
import 'package:tracker_frontend/presentation/helpers/dialog_helper.dart';
import 'package:tracker_frontend/presentation/helpers/ui_helpers.dart';
import 'package:tracker_frontend/presentation/widgets/home/youtube_home_content.dart';
import 'package:tracker_frontend/presentation/widgets/common/wanderer_logo.dart';
import 'package:tracker_frontend/presentation/widgets/common/search_bar_widget.dart';
import 'package:tracker_frontend/presentation/widgets/common/app_sidebar.dart';
import 'create_trip_screen.dart';
import 'trip_detail_screen.dart';
import 'trip_plans_screen.dart';
import 'auth_screen.dart';

/// Home screen showing list of trips
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeRepository _repository = HomeRepository();
  final TextEditingController _searchController = TextEditingController();
  List<Trip> _trips = [];
  List<Trip> _filteredTrips = [];
  bool _isLoading = false;
  String? _error;
  String? _userId;
  String? _username;
  bool _isLoggedIn = false;
  int _selectedSidebarIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadTrips();
    _searchController.addListener(_filterTrips);
  }

  @override
  void dispose() {
    _searchController.dispose();
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
      final trips = await _repository.loadTrips();
      setState(() {
        _trips = trips;
        _filteredTrips = trips;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterTrips() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredTrips = _trips;
      } else {
        _filteredTrips = _trips.where((trip) {
          return trip.name.toLowerCase().contains(query) ||
              trip.username.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _filterTrips();
  }

  Future<void> _logout() async {
    final confirm = await DialogHelper.showLogoutConfirmation(context);

    if (confirm) {
      await _repository.logout();
      if (mounted) {
        await _loadUserInfo();
        await _loadTrips();
      }
    }
  }

  void _handleProfile() {
    UiHelpers.showSuccessMessage(context, 'User Profile coming soon!');
  }

  void _handleSettings() {
    UiHelpers.showSuccessMessage(context, 'User Settings coming soon!');
  }

  void _handleSidebarSelection(int index) {
    setState(() {
      _selectedSidebarIndex = index;
    });

    switch (index) {
      case 0:
        // Already on trips
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TripPlansScreen()),
        );
        break;
      case 2:
        UiHelpers.showSuccessMessage(context, 'Achievements coming soon!');
        break;
      case 3:
        _handleProfile();
        break;
    }
  }

  Future<void> _navigateToAuth() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AuthScreen()),
    );

    if (result == true || mounted) {
      await _loadUserInfo();
      await _loadTrips();
    }
  }

  Future<void> _navigateToCreateTrip() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateTripScreen()),
    );

    if (result == true) {
      _loadTrips();
    }
  }

  void _navigateToTripDetail(Trip trip) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TripDetailScreen(trip: trip)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Row(
          children: [
            const WandererLogo(size: 36),
            const SizedBox(width: 12),
            const Text(
              'Wanderer',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: SearchBarWidget(
                controller: _searchController,
                onSearch: (_) => _filterTrips(),
                onClear: _clearSearch,
              ),
            ),
          ],
        ),
        actions: [
          if (!_isLoggedIn)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: TextButton.icon(
                onPressed: _navigateToAuth,
                icon: const Icon(Icons.login, color: Colors.white),
                label: const Text(
                  'Login',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
      drawer: AppSidebar(
        username: _username,
        userId: _userId,
        selectedIndex: _selectedSidebarIndex,
        onItemSelected: _handleSidebarSelection,
        onLogout: _logout,
        onSettings: _handleSettings,
      ),
      body: YouTubeHomeContent(
        isLoading: _isLoading,
        error: _error,
        trips: _filteredTrips,
        isLoggedIn: _isLoggedIn,
        currentUserId: _userId,
        onRefresh: _loadTrips,
        onTripTap: _navigateToTripDetail,
        onLoginPressed: _navigateToAuth,
      ),
      floatingActionButton: _username != null
          ? FloatingActionButton.extended(
              onPressed: _navigateToCreateTrip,
              icon: const Icon(Icons.add),
              label: const Text('Create Trip'),
            )
          : null,
    );
  }
}
