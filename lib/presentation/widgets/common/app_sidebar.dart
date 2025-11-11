import 'package:flutter/material.dart';
import 'package:tracker_frontend/presentation/helpers/page_transitions.dart';
import 'package:tracker_frontend/presentation/helpers/ui_helpers.dart';
import 'package:tracker_frontend/presentation/screens/home_screen.dart';
import 'package:tracker_frontend/presentation/screens/trip_plans_screen.dart';
import 'package:tracker_frontend/presentation/screens/profile_screen.dart';

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
        // Navigate to Trips (Home)
        if (selectedIndex != 0) {
          // Use slideUp transition when coming from detail screens (index -1)
          if (selectedIndex == -1) {
            Navigator.pushReplacement(
              context,
              PageTransitions.slideUp(const HomeScreen()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          }
        }
        break;
      case 1:
        // Navigate to Trip Plans
        Navigator.push(
          context,
          PageTransitions.slideLeft(const TripPlansScreen()),
        );
        break;
      case 2:
        // Achievements coming soon
        UiHelpers.showSuccessMessage(context, 'Achievements coming soon!');
        break;
      case 3:
        // Navigate to Profile
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
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Trip Plans'),
            selected: selectedIndex == 1,
            enabled: isLoggedIn,
            onTap: isLoggedIn ? () => _handleNavigation(context, 1) : null,
          ),
          ListTile(
            leading: const Icon(Icons.emoji_events),
            title: const Text('Achievements'),
            selected: selectedIndex == 2,
            enabled: isLoggedIn,
            onTap: isLoggedIn ? () => _handleNavigation(context, 2) : null,
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('My Profile'),
            selected: selectedIndex == 3,
            enabled: isLoggedIn,
            onTap: isLoggedIn ? () => _handleNavigation(context, 3) : null,
          ),
          const Divider(),
          if (isLoggedIn) ...[
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
        ],
      ),
    );
  }
}
