import 'package:flutter/material.dart';

/// Sidebar navigation for the app
class AppSidebar extends StatelessWidget {
  final String? username;
  final String? userId;
  final int selectedIndex;
  final Function(int) onItemSelected;
  final VoidCallback? onLogout;
  final VoidCallback? onSettings;

  const AppSidebar({
    super.key,
    this.username,
    this.userId,
    required this.selectedIndex,
    required this.onItemSelected,
    this.onLogout,
    this.onSettings,
  });

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
            onTap: () {
              onItemSelected(0);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Trip Plans'),
            selected: selectedIndex == 1,
            enabled: isLoggedIn,
            onTap: isLoggedIn
                ? () {
                    onItemSelected(1);
                    Navigator.pop(context);
                  }
                : null,
          ),
          ListTile(
            leading: const Icon(Icons.emoji_events),
            title: const Text('Achievements'),
            selected: selectedIndex == 2,
            enabled: isLoggedIn,
            onTap: isLoggedIn
                ? () {
                    onItemSelected(2);
                    Navigator.pop(context);
                  }
                : null,
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('My Profile'),
            selected: selectedIndex == 3,
            enabled: isLoggedIn,
            onTap: isLoggedIn
                ? () {
                    Navigator.pop(context); // Close drawer first
                    onItemSelected(3); // Then trigger navigation
                  }
                : null,
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
