import 'package:flutter/material.dart';
import 'package:tracker_frontend/presentation/widgets/common/wanderer_logo.dart';
import 'package:tracker_frontend/presentation/widgets/common/search_bar_widget.dart';

/// Reusable AppBar for the Wanderer application
class WandererAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController searchController;
  final VoidCallback? onSearch;
  final VoidCallback? onClear;
  final bool isLoggedIn;
  final VoidCallback? onLoginPressed;
  final String? username;
  final String? userId;
  final VoidCallback? onProfile;
  final VoidCallback? onSettings;
  final VoidCallback? onLogout;

  const WandererAppBar({
    super.key,
    required this.searchController,
    this.onSearch,
    this.onClear,
    required this.isLoggedIn,
    this.onLoginPressed,
    this.username,
    this.userId,
    this.onProfile,
    this.onSettings,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
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
              controller: searchController,
              onSearch: (_) => onSearch?.call(),
              onClear: onClear ?? () => searchController.clear(),
            ),
          ),
        ],
      ),
      actions: [
        if (!isLoggedIn && onLoginPressed != null)
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: TextButton.icon(
              onPressed: onLoginPressed,
              icon: const Icon(Icons.login, color: Colors.white),
              label: const Text(
                'Login',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        if (isLoggedIn && username != null)
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: PopupMenuButton<String>(
              icon: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(
                  username![0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              tooltip: 'Profile',
              onSelected: (value) {
                switch (value) {
                  case 'profile':
                    onProfile?.call();
                    break;
                  case 'settings':
                    onSettings?.call();
                    break;
                  case 'logout':
                    onLogout?.call();
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem<String>(
                  enabled: false,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              child: Text(
                                username![0].toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    username!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  if (userId != null)
                                    Text(
                                      'ID: ${userId!.substring(0, 8)}...',
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
                        const Divider(),
                      ],
                    ),
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'profile',
                  child: Row(
                    children: [
                      Icon(Icons.person),
                      SizedBox(width: 12),
                      Text('User Profile'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'settings',
                  child: Row(
                    children: [
                      Icon(Icons.settings),
                      SizedBox(width: 12),
                      Text('Settings'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.red),
                      SizedBox(width: 12),
                      Text('Logout', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
