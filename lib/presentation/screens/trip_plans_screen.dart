import 'package:flutter/material.dart';
import 'package:tracker_frontend/data/models/trip_models.dart';
import 'package:tracker_frontend/data/services/trip_plan_service.dart';
import 'package:tracker_frontend/data/repositories/home_repository.dart';
import 'package:tracker_frontend/presentation/helpers/dialog_helper.dart';
import 'package:tracker_frontend/presentation/helpers/ui_helpers.dart';
import 'package:tracker_frontend/presentation/widgets/common/wanderer_app_bar.dart';
import 'package:tracker_frontend/presentation/widgets/common/app_sidebar.dart';
import 'package:tracker_frontend/presentation/widgets/trip_plans/trip_plans_content.dart';
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
  final int _selectedSidebarIndex = 1; // Trip Plans is index 1

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

  void _handleTripPlanTap(TripPlan plan) {
    UiHelpers.showSuccessMessage(context, 'Trip plan details coming soon!');
  }

  void _handleCreatePlan() {
    UiHelpers.showSuccessMessage(
      context,
      'Create trip plan feature coming soon!',
    );
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
        onLoginPressed: _navigateToAuth,
        onCreatePressed: _handleCreatePlan,
      ),
    );
  }
}
