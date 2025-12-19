import 'package:flutter/material.dart';
import 'package:tracker_frontend/data/models/trip_models.dart';
import 'package:tracker_frontend/data/repositories/home_repository.dart';
import 'package:tracker_frontend/data/services/trip_service.dart';
import 'package:tracker_frontend/presentation/helpers/dialog_helper.dart';
import 'package:tracker_frontend/presentation/helpers/ui_helpers.dart';
import 'package:tracker_frontend/presentation/helpers/page_transitions.dart';
import 'package:tracker_frontend/presentation/widgets/home/youtube_home_content.dart';
import 'package:tracker_frontend/presentation/widgets/common/wanderer_app_bar.dart';
import 'package:tracker_frontend/presentation/widgets/common/app_sidebar.dart';
import 'create_trip_screen.dart';
import 'trip_detail_screen.dart';
import 'profile_screen.dart';
import 'auth_screen.dart';

/// Home screen showing list of trips
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeRepository _repository = HomeRepository();
  final TripService _tripService = TripService();
  final TextEditingController _searchController = TextEditingController();
  List<Trip> _trips = [];
  List<Trip> _filteredTrips = [];
  bool _isLoading = false;
  String? _error;
  String? _userId;
  String? _username;
  bool _isLoggedIn = false;
  final int _selectedSidebarIndex = 0;

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
    Navigator.push(
      context,
      PageTransitions.slideRight(const ProfileScreen()),
    ).then((result) {
      if (result == true && mounted) {
        // User logged out from profile screen
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

  void _navigateToTripDetail(Trip trip) async {
    final result = await Navigator.push(
      context,
      PageTransitions.slideUp(TripDetailScreen(trip: trip)),
    );

    // Refresh if user logged out from trip detail screen
    if (result == true && mounted) {
      await _loadUserInfo();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WandererAppBar(
        searchController: _searchController,
        onSearch: _filterTrips,
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
      body: YouTubeHomeContent(
        isLoading: _isLoading,
        error: _error,
        trips: _filteredTrips,
        isLoggedIn: _isLoggedIn,
        currentUserId: _userId,
        onRefresh: _loadTrips,
        onTripTap: _navigateToTripDetail,
        onLoginPressed: _navigateToAuth,
        onDeleteTrip: _handleDeleteTrip, // Pass the delete handler
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
