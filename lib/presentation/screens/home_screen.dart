import 'package:flutter/material.dart';
import 'package:tracker_frontend/data/models/trip_models.dart';
import 'package:tracker_frontend/data/repositories/home_repository.dart';
import 'package:tracker_frontend/presentation/helpers/dialog_helper.dart';
import 'package:tracker_frontend/presentation/helpers/ui_helpers.dart';
import 'package:tracker_frontend/presentation/widgets/home/home_content.dart';
import 'package:tracker_frontend/presentation/widgets/home/profile_menu.dart';
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
  final HomeRepository _repository = HomeRepository();
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
    UiHelpers.showSuccessMessage(
      context,
      'User Profile coming soon!',
    );
  }

  Future<void> _navigateToAuth() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AuthScreen(),
      ),
    );

    if (result == true || mounted) {
      await _loadUserInfo();
      await _loadTrips();
    }
  }

  Future<void> _navigateToCreateTrip() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateTripScreen(),
      ),
    );

    if (result == true) {
      _loadTrips();
    }
  }

  void _navigateToTripDetail(Trip trip) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TripDetailScreen(trip: trip),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLoggedIn ? 'My Trips' : 'Public Trips'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_username != null)
            ProfileMenu(
              username: _username!,
              userId: _userId,
              onLogout: _logout,
              onProfile: _handleProfile,
            )
          else
            TextButton.icon(
              onPressed: _navigateToAuth,
              icon: const Icon(Icons.login, color: Colors.white),
              label: const Text(
                'Login',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: HomeContent(
        isLoading: _isLoading,
        error: _error,
        trips: _trips,
        isLoggedIn: _isLoggedIn,
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
