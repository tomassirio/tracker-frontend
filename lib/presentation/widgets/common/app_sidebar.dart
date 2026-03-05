import 'package:flutter/material.dart';
import 'package:wanderer_frontend/presentation/helpers/page_transitions.dart';
import 'package:wanderer_frontend/presentation/helpers/ui_helpers.dart';
import 'package:wanderer_frontend/presentation/helpers/auth_navigation_helper.dart';
import 'package:wanderer_frontend/presentation/screens/admin_users_screen.dart';
import 'package:wanderer_frontend/presentation/screens/auth_screen.dart';
import 'package:wanderer_frontend/presentation/screens/home_screen.dart';
import 'package:wanderer_frontend/presentation/screens/trip_maintenance_screen.dart';
import 'package:wanderer_frontend/presentation/screens/trip_promotion_screen.dart';
import 'package:url_launcher/url_launcher.dart';

/// Sidebar navigation for the app
class AppSidebar extends StatelessWidget {
  final String? username;
  final String? userId;
  final String? displayName;
  final String? avatarUrl;
  final int selectedIndex;
  final VoidCallback? onLogout;
  final VoidCallback? onSettings;
  final bool isAdmin;

  const AppSidebar({
    super.key,
    this.username,
    this.userId,
    this.displayName,
    this.avatarUrl,
    required this.selectedIndex,
    this.onLogout,
    this.onSettings,
    this.isAdmin = false,
  });

  void _handleNavigation(BuildContext context, int index) {
    // Close drawer first
    Navigator.pop(context);

    // If already on the selected screen, do nothing
    if (selectedIndex == index) {
      return;
    }

    switch (index) {
      case 0:
        // Navigate to Trips (Home) - center position
        if (selectedIndex == -1) {
          // From trip detail - pop all routes until we're back at home
          Navigator.popUntil(context, (route) => route.isFirst);
        } else if (selectedIndex == 1) {
          // Coming from Trip Plans (left) - slide right
          Navigator.pushReplacement(
            context,
            PageTransitions.slideRight(const HomeScreen()),
          );
        } else if (selectedIndex == 3) {
          // Coming from Profile (right) - slide left
          Navigator.pushReplacement(
            context,
            PageTransitions.slideLeft(const HomeScreen()),
          );
        } else if (selectedIndex != 0) {
          // From other screens - use default
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
        break;
      case 1:
        // Navigate to Trip Plans (left of home) - requires auth
        AuthNavigationHelper.navigateToTripPlans(context);
        break;
      case 2:
        // Navigate to Friends & Followers - requires auth
        AuthNavigationHelper.navigateToFriendsFollowers(context);
        break;
      case 3:
        // Navigate to Achievements - requires auth
        AuthNavigationHelper.navigateToAchievements(context);
        break;
      case 4:
        // Navigate to Profile (right of home) - requires auth
        AuthNavigationHelper.navigateToOwnProfile(context);
        break;
      case 5:
        // Navigate to Trip Promotion Management (admin only)
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const TripPromotionScreen(),
          ),
        );
        break;
      case 6:
        // Navigate to User Management (admin only)
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AdminUsersScreen(),
          ),
        );
        break;
      case 7:
        // Navigate to Trip Data Maintenance (admin only)
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const TripMaintenanceScreen(),
          ),
        );
        break;
    }
  }

  Future<void> _launchBuyMeACoffee(BuildContext context) async {
    final url = Uri.parse('https://buymeacoffee.com/tomassirio');
    try {
      final launched =
          await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        UiHelpers.showErrorMessage(
          context,
          'Could not open Buy Me a Coffee link',
        );
      }
    } catch (e) {
      if (context.mounted) {
        UiHelpers.showErrorMessage(
          context,
          'Error opening link: $e',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = username != null;

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            accountName: Text(
              displayName ?? username ?? 'Guest',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: isLoggedIn ? Text('@${username ?? ''}') : null,
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: avatarUrl != null && avatarUrl!.isNotEmpty
                  ? NetworkImage(avatarUrl!)
                  : null,
              child: avatarUrl == null || avatarUrl!.isEmpty
                  ? (isLoggedIn
                      ? Text(
                          (displayName ?? username ?? '?')
                              .substring(0, 1)
                              .toUpperCase(),
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        )
                      : Icon(
                          Icons.person_outline,
                          size: 40,
                          color: Theme.of(context).colorScheme.primary,
                        ))
                  : null,
            ),
            otherAccountsPictures: isLoggedIn
                ? [
                    IconButton(
                      icon: const Icon(Icons.person, color: Colors.white),
                      onPressed: () => _handleNavigation(context, 4),
                      tooltip: 'My Profile',
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                        onSettings?.call();
                      },
                      tooltip: 'Settings',
                    ),
                  ]
                : null,
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: const Icon(Icons.map),
                  title: const Text('Trips'),
                  selected: selectedIndex == 0,
                  onTap: () => _handleNavigation(context, 0),
                ),
                if (isLoggedIn) ...[
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Trip Plans'),
                    selected: selectedIndex == 1,
                    onTap: () => _handleNavigation(context, 1),
                  ),
                  ListTile(
                    leading: const Icon(Icons.people),
                    title: const Text('Friends'),
                    selected: selectedIndex == 2,
                    onTap: () => _handleNavigation(context, 2),
                  ),
                  ListTile(
                    leading: const Icon(Icons.emoji_events),
                    title: const Text('Achievements'),
                    selected: selectedIndex == 3,
                    onTap: () => _handleNavigation(context, 3),
                  ),
                  if (isAdmin) ...[
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.admin_panel_settings),
                      title: const Text('Trip Promotion'),
                      selected: selectedIndex == 5,
                      onTap: () => _handleNavigation(context, 5),
                    ),
                    ListTile(
                      leading: const Icon(Icons.people_outline),
                      title: const Text('User Management'),
                      selected: selectedIndex == 6,
                      onTap: () => _handleNavigation(context, 6),
                    ),
                    ListTile(
                      leading: const Icon(Icons.build_outlined),
                      title: const Text('Trip Data Maintenance'),
                      selected: selectedIndex == 7,
                      onTap: () => _handleNavigation(context, 7),
                    ),
                  ],
                ],
              ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.coffee),
            title: const Text('Buy Me a Coffee'),
            onTap: () {
              Navigator.pop(context);
              _launchBuyMeACoffee(context);
            },
          ),
          if (isLoggedIn)
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                onLogout?.call();
              },
            ),
          if (!isLoggedIn)
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Log In'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to auth screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AuthScreen(),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
