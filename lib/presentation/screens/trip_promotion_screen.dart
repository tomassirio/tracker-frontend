import 'package:flutter/material.dart' hide Visibility;
import 'package:tracker_frontend/core/constants/enums.dart';
import 'package:tracker_frontend/data/models/trip_models.dart';
import 'package:tracker_frontend/data/services/admin_service.dart';
import 'package:tracker_frontend/data/repositories/home_repository.dart';
import 'package:tracker_frontend/presentation/helpers/ui_helpers.dart';
import 'package:tracker_frontend/presentation/widgets/common/wanderer_app_bar.dart';
import 'package:tracker_frontend/presentation/widgets/common/app_sidebar.dart';

/// Trip Promotion Management screen for admins
class TripPromotionScreen extends StatefulWidget {
  const TripPromotionScreen({super.key});

  @override
  State<TripPromotionScreen> createState() => _TripPromotionScreenState();
}

class _TripPromotionScreenState extends State<TripPromotionScreen> {
  final AdminService _adminService = AdminService();
  final HomeRepository _homeRepository = HomeRepository();
  final TextEditingController _searchController = TextEditingController();

  List<Trip> _allTrips = [];
  List<PromotedTrip> _promotedTrips = [];
  List<Trip> _filteredTrips = [];
  bool _isLoading = false;
  bool _isLoadingPromoted = false;
  String? _error;
  String? _userId;
  String? _username;
  bool _isLoggedIn = false;
  bool _isAdmin = false;
  final int _selectedSidebarIndex = 5; // Admin panel index

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadTrips();
    _loadPromotedTrips();
    _searchController.addListener(_filterTrips);
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
    final isAdmin = await _homeRepository.isAdmin();

    setState(() {
      _username = username;
      _userId = userId;
      _isLoggedIn = isLoggedIn;
      _isAdmin = isAdmin;
    });
  }

  Future<void> _loadTrips() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Get all trips (admin only)
      final trips = await _adminService.getAllTrips();

      // Filter to only show public trips with status: created, in_progress, or paused
      final promotableTrips = trips.where((trip) {
        return trip.visibility == Visibility.public &&
            (trip.status == TripStatus.created ||
                trip.status == TripStatus.inProgress ||
                trip.status == TripStatus.paused);
      }).toList();

      setState(() {
        _allTrips = promotableTrips;
        _filteredTrips = promotableTrips;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadPromotedTrips() async {
    setState(() {
      _isLoadingPromoted = true;
    });

    try {
      final promoted = await _adminService.getPromotedTrips();
      setState(() {
        _promotedTrips = promoted;
        _isLoadingPromoted = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingPromoted = false;
      });
    }
  }

  void _filterTrips() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredTrips = _allTrips;
      } else {
        _filteredTrips = _allTrips.where((trip) {
          return trip.name.toLowerCase().contains(query) ||
              trip.username.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  Future<void> _promoteTrip(Trip trip) async {
    final donationLinkController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Promote Trip'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Trip: ${trip.name}'),
            const SizedBox(height: 8),
            Text('By: ${trip.username}'),
            const SizedBox(height: 16),
            TextField(
              controller: donationLinkController,
              decoration: const InputDecoration(
                labelText: 'Donation Link (optional)',
                hintText: 'https://...',
                border: OutlineInputBorder(),
              ),
              maxLength: 500,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Promote'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      try {
        final donationLink = donationLinkController.text.trim();
        await _adminService.promoteTrip(
          trip.id,
          donationLink: donationLink.isEmpty ? null : donationLink,
        );

        if (mounted) {
          UiHelpers.showSuccessMessage(context, 'Trip promoted successfully!');
          _loadPromotedTrips();
        }
      } catch (e) {
        if (mounted) {
          UiHelpers.showErrorMessage(context, 'Failed to promote trip: $e');
        }
      }
    }
  }

  Future<void> _unpromoteTrip(String tripId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unpromote Trip'),
        content: const Text('Are you sure you want to unpromote this trip?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Unpromote'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await _adminService.unpromoteTrip(tripId);

        if (mounted) {
          UiHelpers.showSuccessMessage(
            context,
            'Trip unpromoted successfully!',
          );
          _loadPromotedTrips();
        }
      } catch (e) {
        if (mounted) {
          UiHelpers.showErrorMessage(context, 'Failed to unpromote trip: $e');
        }
      }
    }
  }

  Future<void> _handleLogout() async {
    await _homeRepository.logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const TripPromotionScreen()),
        (route) => false,
      );
    }
  }

  void _handleSettings() {
    UiHelpers.showSuccessMessage(context, 'Settings coming soon!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WandererAppBar(
        title: 'Trip Promotion Management',
        showBackButton: true,
        onBackPressed: () => Navigator.pop(context),
      ),
      drawer: AppSidebar(
        username: _username,
        userId: _userId,
        selectedIndex: _selectedSidebarIndex,
        onLogout: _handleLogout,
        onSettings: _handleSettings,
        isAdmin: _isAdmin,
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
            Text('Error: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTrips,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await _loadTrips();
        await _loadPromotedTrips();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPromotedTripsSection(),
            const SizedBox(height: 24),
            _buildPromotableTripsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildPromotedTripsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.star, color: Colors.amber),
                SizedBox(width: 8),
                Text(
                  'Currently Promoted Trips',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoadingPromoted)
              const Center(child: CircularProgressIndicator())
            else if (_promotedTrips.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'No promoted trips',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _promotedTrips.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final promoted = _promotedTrips[index];
                  return ListTile(
                    leading: const Icon(Icons.star, color: Colors.amber),
                    title: Text(promoted.tripName),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('By: ${promoted.username}'),
                        if (promoted.donationLink != null)
                          Text(
                            'Donation: ${promoted.donationLink}',
                            style: const TextStyle(fontSize: 12),
                          ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () => _unpromoteTrip(promoted.tripId),
                      tooltip: 'Unpromote',
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromotableTripsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.public),
                SizedBox(width: 8),
                Text(
                  'Promotable Trips',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Public trips that are created, in progress, or paused',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search trips',
                hintText: 'Search by trip name or username',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            if (_filteredTrips.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'No promotable trips found',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _filteredTrips.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final trip = _filteredTrips[index];
                  final isPromoted = _promotedTrips
                      .any((promoted) => promoted.tripId == trip.id);

                  return ListTile(
                    leading: Icon(
                      _getStatusIcon(trip.status),
                      color: _getStatusColor(trip.status),
                    ),
                    title: Text(trip.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('By: ${trip.username}'),
                        Text(
                          'Status: ${_getStatusLabel(trip.status)}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    trailing: isPromoted
                        ? const Chip(
                            label: Text('Promoted'),
                            backgroundColor: Colors.amber,
                          )
                        : ElevatedButton.icon(
                            onPressed: () => _promoteTrip(trip),
                            icon: const Icon(Icons.star, size: 16),
                            label: const Text('Promote'),
                          ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(TripStatus status) {
    switch (status) {
      case TripStatus.created:
        return Icons.fiber_new;
      case TripStatus.inProgress:
        return Icons.directions_run;
      case TripStatus.paused:
        return Icons.pause_circle;
      case TripStatus.finished:
        return Icons.check_circle;
    }
  }

  Color _getStatusColor(TripStatus status) {
    switch (status) {
      case TripStatus.created:
        return Colors.blue;
      case TripStatus.inProgress:
        return Colors.green;
      case TripStatus.paused:
        return Colors.orange;
      case TripStatus.finished:
        return Colors.grey;
    }
  }

  String _getStatusLabel(TripStatus status) {
    switch (status) {
      case TripStatus.created:
        return 'Created';
      case TripStatus.inProgress:
        return 'In Progress';
      case TripStatus.paused:
        return 'Paused';
      case TripStatus.finished:
        return 'Finished';
    }
  }
}
