import 'package:flutter/material.dart';
import 'package:tracker_frontend/presentation/helpers/page_transitions.dart';
import 'package:tracker_frontend/presentation/helpers/ui_helpers.dart';
import 'package:tracker_frontend/presentation/screens/auth_screen.dart';
import 'package:tracker_frontend/presentation/screens/home_screen.dart';
import 'package:tracker_frontend/presentation/screens/trip_plans_screen.dart';
import 'package:tracker_frontend/presentation/screens/profile_screen.dart';
import 'package:tracker_frontend/presentation/screens/friends_followers_screen.dart';

/// Sidebar navigation for the app
class AppSidebar extends StatelessWidget {
  final String? username;
  final String? userId;
  final int selectedIndex;
  final VoidCallback? onLogout;
  final VoidCallback? onSettings;

  const AppSidebar({
    super.key,
    this.username,
    this.userId,
    required this.selectedIndex,
    this.onLogout,
    this.onSettings,
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
        // Navigate to Trip Plans (left of home)
        Navigator.push(
          context,
          PageTransitions.slideLeft(const TripPlansScreen()),
        );
        break;
      case 2:
        // Navigate to Friends & Followers
        Navigator.push(
          context,
          PageTransitions.slideUp(const FriendsFollowersScreen()),
        );
        break;
      case 3:
        // Achievements coming soon
        UiHelpers.showSuccessMessage(context, 'Achievements coming soon!');
        break;
      case 4:
        // Navigate to Profile (right of home)
        Navigator.push(
          context,
          PageTransitions.slideRight(const ProfileScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = username != null;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            accountName: Text(
              username ?? 'Guest',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: isLoggedIn ? Text('ID: ${userId ?? 'N/A'}') : null,
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                isLoggedIn ? Icons.person : Icons.person_outline,
                size: 40,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
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
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('My Profile'),
              selected: selectedIndex == 4,
              onTap: () => _handleNavigation(context, 4),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                onSettings?.call();
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                onLogout?.call();
              },
            ),
          ],
          if (!isLoggedIn) ...[
            const Divider(),
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
        ],
      ),
    );
  }
}
