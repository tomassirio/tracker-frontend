import 'package:flutter/material.dart';
import 'package:tracker_frontend/data/models/trip_models.dart';
import 'package:tracker_frontend/data/services/trip_plan_service.dart';
import 'package:tracker_frontend/presentation/helpers/dialog_helper.dart';
import 'package:tracker_frontend/presentation/helpers/ui_helpers.dart';
import 'package:tracker_frontend/presentation/widgets/common/wanderer_logo.dart';
import 'package:tracker_frontend/presentation/widgets/common/search_bar_widget.dart';
import 'package:tracker_frontend/presentation/widgets/common/app_sidebar.dart';
import 'package:tracker_frontend/data/repositories/home_repository.dart';
import 'auth_screen.dart';

/// Trip Plans screen showing list of planned trips
class TripPlansScreen extends StatefulWidget {
  const TripPlansScreen({super.key});

  @override
  State<TripPlansScreen> createState() => _TripPlansScreenState();
}

class _TripPlansScreenState extends State<TripPlansScreen> {
  final TripPlanService _tripPlanService = TripPlanService();
  final HomeRepository _homeRepository = HomeRepository();
  final TextEditingController _searchController = TextEditingController();
  List<TripPlan> _tripPlans = [];
  List<TripPlan> _filteredPlans = [];
  bool _isLoading = false;
  String? _error;
  String? _userId;
  String? _username;
  bool _isLoggedIn = false;
  int _selectedSidebarIndex = 1; // Trip Plans is index 1

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadTripPlans();
    _searchController.addListener(_filterPlans);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserInfo() async {
    final username = await _homeRepository.getCurrentUsername();
    final userId = await _homeRepository.getCurrentUserId();
    final isLoggedIn = await _homeRepository.isLoggedIn();

    setState(() {
      _username = username;
      _userId = userId;
      _isLoggedIn = isLoggedIn;
    });
  }

  Future<void> _loadTripPlans() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Get user's trip plans
      final plans = await _tripPlanService.getUserTripPlans();
      setState(() {
        _tripPlans = plans;
        _filteredPlans = plans;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterPlans() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredPlans = _tripPlans;
      } else {
        _filteredPlans = _tripPlans.where((plan) {
          return plan.name.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _filterPlans();
  }

  Future<void> _logout() async {
    final confirm = await DialogHelper.showLogoutConfirmation(context);

    if (confirm) {
      await _homeRepository.logout();
      if (mounted) {
        await _loadUserInfo();
        await _loadTripPlans();
      }
    }
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
        Navigator.pop(context); // Go back to trips
        break;
      case 1:
        // Already on trip plans
        break;
      case 2:
        UiHelpers.showSuccessMessage(context, 'Achievements coming soon!');
        break;
      case 3:
        UiHelpers.showSuccessMessage(context, 'Profile coming soon!');
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
      await _loadTripPlans();
    }
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
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: SearchBarWidget(
                controller: _searchController,
                onSearch: (_) => _filterPlans(),
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
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (!_isLoggedIn) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.calendar_today, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 24),
              Text(
                'Login Required',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Please log in to view your trip plans',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _navigateToAuth,
                icon: const Icon(Icons.login),
                label: const Text('Login'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Error loading trip plans',
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadTripPlans,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_filteredPlans.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.calendar_today, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 24),
              Text(
                'No Trip Plans Yet',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Start planning your next adventure!',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  UiHelpers.showSuccessMessage(
                    context,
                    'Create trip plan feature coming soon!',
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Create Trip Plan'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // If we had trip plans, they would be displayed in a grid here
    return const Center(child: Text('Trip plans feature coming soon'));
  }
}
