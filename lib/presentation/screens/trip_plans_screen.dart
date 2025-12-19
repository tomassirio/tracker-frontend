import 'package:flutter/material.dart' hide Visibility;
import 'package:tracker_frontend/core/constants/enums.dart';
import 'package:tracker_frontend/data/models/trip_models.dart';
import 'package:tracker_frontend/data/services/trip_plan_service.dart';
import 'package:tracker_frontend/data/services/trip_service.dart';
import 'package:tracker_frontend/data/repositories/home_repository.dart';
import 'package:tracker_frontend/presentation/helpers/dialog_helper.dart';
import 'package:tracker_frontend/presentation/helpers/ui_helpers.dart';
import 'package:tracker_frontend/presentation/widgets/common/wanderer_app_bar.dart';
import 'package:tracker_frontend/presentation/widgets/common/app_sidebar.dart';
import 'package:tracker_frontend/presentation/widgets/trip_plans/trip_plans_content.dart';
import 'auth_screen.dart';
import 'create_trip_plan_screen.dart';
import 'trip_detail_screen.dart';
import 'trip_plan_detail_screen.dart';

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
  late final TripService _tripService;
  List<TripPlan> _tripPlans = [];
  List<TripPlan> _filteredPlans = [];
  bool _isLoading = false;
  String? _error;
  String? _userId;
  String? _username;
  bool _isLoggedIn = false;
  final int _selectedSidebarIndex = 1; // Trip Plans is index 1

  @override
  void initState() {
    super.initState();
    _tripService = TripService();
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

  Future<void> _handleTripPlanTap(TripPlan plan) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TripPlanDetailScreen(tripPlan: plan),
      ),
    );

    // Reload trip plans if the plan was modified or deleted
    if (result == true && mounted) {
      await _loadTripPlans();
    }
  }

  Future<void> _handleCreatePlan() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateTripPlanScreen()),
    );

    // Reload trip plans if a new one was created
    if (result == true && mounted) {
      await _loadTripPlans();
    }
  }

  Future<void> _handleCreateTripFromPlan(TripPlan plan) async {
    // Show visibility selection dialog
    final visibility = await showDialog<Visibility>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Trip'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Create a trip from "${plan.name}"'),
            const SizedBox(height: 16),
            const Text(
              'Select visibility:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.public),
              title: const Text('Public'),
              subtitle: const Text('Visible to everyone'),
              onTap: () => Navigator.pop(context, Visibility.public),
            ),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Private'),
              subtitle: const Text('Only visible to you'),
              onTap: () => Navigator.pop(context, Visibility.private),
            ),
            ListTile(
              leading: const Icon(Icons.shield),
              title: const Text('Protected'),
              subtitle: const Text('Visible to friends only'),
              onTap: () => Navigator.pop(context, Visibility.protected),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (visibility == null || !mounted) return;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final trip = await _tripService.createTripFromPlan(plan.id, visibility);
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        UiHelpers.showSuccessMessage(
          context,
          'Trip created successfully from plan!',
        );
        // Navigate to trip detail screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TripDetailScreen(trip: trip),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        UiHelpers.showErrorMessage(context, 'Error creating trip: $e');
      }
    }
  }

  Future<void> _handleDeletePlan(TripPlan plan) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Trip Plan'),
        content: Text(
          'Are you sure you want to delete "${plan.name}"? This action cannot be undone.',
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
      await _tripPlanService.deleteTripPlan(plan.id);
      if (mounted) {
        UiHelpers.showSuccessMessage(context, 'Trip plan deleted');
        await _loadTripPlans();
      }
    } catch (e) {
      if (mounted) {
        UiHelpers.showErrorMessage(context, 'Error deleting trip plan: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WandererAppBar(
        searchController: _searchController,
        onSearch: _filterPlans,
        onClear: _clearSearch,
        isLoggedIn: _isLoggedIn,
        onLoginPressed: _navigateToAuth,
        username: _username,
        userId: _userId,
        onProfile: () {}, // Not used in this screen
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
      body: TripPlansContent(
        isLoading: _isLoading,
        error: _error,
        tripPlans: _filteredPlans,
        isLoggedIn: _isLoggedIn,
        onRefresh: _loadTripPlans,
        onTripPlanTap: _handleTripPlanTap,
        onCreateTripFromPlan: _handleCreateTripFromPlan,
        onDeletePlan: _handleDeletePlan,
        onLoginPressed: _navigateToAuth,
        onCreatePressed: _handleCreatePlan,
      ),
    );
  }
}
