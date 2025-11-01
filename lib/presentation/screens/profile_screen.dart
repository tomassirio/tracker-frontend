import 'package:flutter/material.dart';
import 'package:tracker_frontend/data/models/trip_models.dart';
import 'package:tracker_frontend/data/models/user_models.dart';
import 'package:tracker_frontend/data/repositories/profile_repository.dart';
import 'package:tracker_frontend/presentation/helpers/dialog_helper.dart';
import 'package:tracker_frontend/presentation/helpers/ui_helpers.dart';
import 'package:tracker_frontend/presentation/widgets/common/wanderer_app_bar.dart';
import 'package:tracker_frontend/presentation/widgets/common/app_sidebar.dart';
import 'auth_screen.dart';
import 'trip_detail_screen.dart';
import 'home_screen.dart';
import 'trip_plans_screen.dart';

/// User profile screen showing user information, statistics, and trips
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileRepository _repository = ProfileRepository();
  final TextEditingController _searchController = TextEditingController();
  UserProfile? _profile;
  List<Trip> _userTrips = [];
  bool _isLoadingProfile = false;
  bool _isLoadingTrips = false;
  String? _error;
  bool _isLoggedIn = false;
  int _selectedSidebarIndex = 3; // Profile is index 3

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoadingProfile = true;
      _error = null;
    });

    try {
      final isLoggedIn = await _repository.isLoggedIn();
      setState(() {
        _isLoggedIn = isLoggedIn;
      });

      if (!isLoggedIn) {
        setState(() {
          _isLoadingProfile = false;
          _error = 'You must be logged in to view your profile';
        });
        return;
      }

      final profile = await _repository.getMyProfile();
      setState(() {
        _profile = profile;
        _isLoadingProfile = false;
      });

      // Load user's trips
      _loadUserTrips(profile.id);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoadingProfile = false;
      });
    }
  }

  Future<void> _loadUserTrips(String userId) async {
    setState(() {
      _isLoadingTrips = true;
    });

    try {
      final trips = await _repository.getUserTrips(userId);
      setState(() {
        _userTrips = trips;
        _isLoadingTrips = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingTrips = false;
      });
      if (mounted) {
        UiHelpers.showErrorMessage(context, 'Failed to load trips: $e');
      }
    }
  }

  Future<void> _logout() async {
    final confirm = await DialogHelper.showLogoutConfirmation(context);

    if (confirm) {
      await _repository.logout();
      if (mounted) {
        Navigator.of(context).pop(true); // Return to previous screen
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
        // Navigate to home/trips screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
        break;
      case 1:
        // Navigate to trip plans screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const TripPlansScreen()),
        );
        break;
      case 2:
        // Achievements coming soon
        UiHelpers.showSuccessMessage(context, 'Achievements coming soon!');
        break;
      case 3:
        // Already on profile screen, do nothing
        break;
    }
  }

  Future<void> _navigateToAuth() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AuthScreen()),
    );

    if (result == true || mounted) {
      await _loadProfile();
    }
  }

  void _navigateToTripDetail(Trip trip) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TripDetailScreen(trip: trip)),
    );
  }

  Future<void> _showEditProfileDialog() async {
    if (_profile == null) return;

    final displayNameController =
        TextEditingController(text: _profile!.displayName);
    final bioController = TextEditingController(text: _profile!.bio);
    final avatarUrlController =
        TextEditingController(text: _profile!.avatarUrl);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: displayNameController,
                decoration: const InputDecoration(
                  labelText: 'Display Name',
                  hintText: 'Your display name',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: bioController,
                decoration: const InputDecoration(
                  labelText: 'Bio',
                  hintText: 'Tell us about yourself',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: avatarUrlController,
                decoration: const InputDecoration(
                  labelText: 'Avatar URL',
                  hintText: 'https://example.com/avatar.jpg',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == true) {
      await _updateProfile(
        displayNameController.text,
        bioController.text,
        avatarUrlController.text,
      );
    }

    displayNameController.dispose();
    bioController.dispose();
    avatarUrlController.dispose();
  }

  Future<void> _updateProfile(
    String displayName,
    String bio,
    String avatarUrl,
  ) async {
    try {
      final request = UpdateProfileRequest(
        displayName: displayName.isEmpty ? null : displayName,
        bio: bio.isEmpty ? null : bio,
        avatarUrl: avatarUrl.isEmpty ? null : avatarUrl,
      );

      final updatedProfile = await _repository.updateProfile(request);
      setState(() {
        _profile = updatedProfile;
      });

      if (mounted) {
        UiHelpers.showSuccessMessage(context, 'Profile updated successfully!');
      }
    } catch (e) {
      if (mounted) {
        UiHelpers.showErrorMessage(context, 'Failed to update profile: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WandererAppBar(
        searchController: _searchController,
        onSearch: () {},
        onClear: () {},
        isLoggedIn: _isLoggedIn,
        onLoginPressed: _navigateToAuth,
        username: _profile?.username,
        userId: _profile?.id,
        onProfile: () {},
        onSettings: _handleSettings,
        onLogout: _logout,
      ),
      drawer: AppSidebar(
        username: _profile?.username,
        userId: _profile?.id,
        selectedIndex: _selectedSidebarIndex,
        onItemSelected: _handleSidebarSelection,
        onLogout: _logout,
        onSettings: _handleSettings,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoadingProfile) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            if (!_isLoggedIn) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _navigateToAuth,
                child: const Text('Login'),
              ),
            ],
          ],
        ),
      );
    }

    if (_profile == null) {
      return const Center(child: Text('No profile data available'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 24),
          _buildStatsRow(),
          const SizedBox(height: 24),
          _buildTripsSection(),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: _profile!.avatarUrl != null
                      ? NetworkImage(_profile!.avatarUrl!)
                      : null,
                  child: _profile!.avatarUrl == null
                      ? Text(
                          _profile!.username.substring(0, 1).toUpperCase(),
                          style: const TextStyle(fontSize: 32),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _profile!.displayName ?? _profile!.username,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '@${_profile!.username}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _profile!.email,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: _showEditProfileDialog,
                  tooltip: 'Edit Profile',
                ),
              ],
            ),
            if (_profile!.bio != null) ...[
              const SizedBox(height: 16),
              Text(
                _profile!.bio!,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatCard('Trips', _profile!.tripsCount.toString()),
        _buildStatCard('Followers', _profile!.followersCount.toString()),
        _buildStatCard('Following', _profile!.followingCount.toString()),
      ],
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTripsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'My Trips',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        if (_isLoadingTrips)
          const Center(child: CircularProgressIndicator())
        else if (_userTrips.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text('No trips yet'),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
            ),
            itemCount: _userTrips.length,
            itemBuilder: (context, index) {
              return _buildTripCard(_userTrips[index]);
            },
          ),
      ],
    );
  }

  Widget _buildTripCard(Trip trip) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _navigateToTripDetail(trip),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                color: Colors.blue[100],
                child: const Icon(
                  Icons.map,
                  size: 48,
                  color: Colors.blue,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trip.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    trip.status.toString().split('.').last,
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
      ),
    );
  }
}
