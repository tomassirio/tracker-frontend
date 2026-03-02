import 'package:flutter/material.dart';
import 'package:tracker_frontend/presentation/widgets/common/wanderer_logo.dart';
import 'package:tracker_frontend/presentation/widgets/common/search_bar_widget.dart';
import 'package:tracker_frontend/presentation/helpers/ui_helpers.dart';

/// Reusable AppBar for the Wanderer application
class WandererAppBar extends StatefulWidget implements PreferredSizeWidget {
  final TextEditingController searchController;
  final VoidCallback? onSearch;
  final VoidCallback? onClear;
  final bool isLoggedIn;
  final VoidCallback? onLoginPressed;
  final String? username;
  final String? userId;
  final String? displayName;
  final String? avatarUrl;
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
    this.displayName,
    this.avatarUrl,
    this.onProfile,
    this.onSettings,
    this.onLogout,
  });

  @override
  State<WandererAppBar> createState() => _WandererAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _WandererAppBarState extends State<WandererAppBar> {
  bool _isSearchExpanded = false;

  /// Get the initial letter for the avatar, preferring displayName over username
  String get _avatarInitial {
    final name = widget.displayName ?? widget.username ?? '';
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  void _toggleSearch() {
    setState(() {
      _isSearchExpanded = !_isSearchExpanded;
      if (!_isSearchExpanded) {
        // Clear search when closing
        widget.searchController.clear();
        widget.onClear?.call();
      }
    });
  }

  void _showNotImplementedMessage() {
    UiHelpers.showInfoMessage(
      context,
      'Notifications feature not yet implemented',
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      centerTitle: true,
      title: _isSearchExpanded
          ? SearchBarWidget(
              controller: widget.searchController,
              onSearch: (_) => widget.onSearch?.call(),
              onClear: () {
                widget.searchController.clear();
                widget.onClear?.call();
              },
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () {
                    // Navigate to home screen by popping all routes until first route
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  borderRadius: BorderRadius.circular(18),
                  child: const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: WandererLogo(size: 36),
                  ),
                ),
                const SizedBox(width: 12),
                const Flexible(
                  child: Text(
                    'Wanderer',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
      actions: [
        // Search icon
        if (_isSearchExpanded)
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Close search',
            onPressed: _toggleSearch,
          )
        else
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search',
            onPressed: _toggleSearch,
          ),
        // Notifications icon (only for logged in users)
        if (widget.isLoggedIn)
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            tooltip: 'Notifications',
            onPressed: _showNotImplementedMessage,
          ),
        if (!widget.isLoggedIn && widget.onLoginPressed != null)
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: TextButton.icon(
              onPressed: widget.onLoginPressed,
              icon: const Icon(Icons.login, color: Colors.white),
              label: const Text('Login', style: TextStyle(color: Colors.white)),
            ),
          ),
        if (widget.isLoggedIn && widget.username != null)
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: PopupMenuButton<String>(
              icon: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                backgroundImage:
                    widget.avatarUrl != null && widget.avatarUrl!.isNotEmpty
                        ? NetworkImage(widget.avatarUrl!)
                        : null,
                child: widget.avatarUrl == null || widget.avatarUrl!.isEmpty
                    ? Text(
                        _avatarInitial,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              tooltip: 'Profile',
              onSelected: (value) {
                switch (value) {
                  case 'profile':
                    widget.onProfile?.call();
                    break;
                  case 'settings':
                    widget.onSettings?.call();
                    break;
                  case 'logout':
                    widget.onLogout?.call();
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
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              backgroundImage: widget.avatarUrl != null &&
                                      widget.avatarUrl!.isNotEmpty
                                  ? NetworkImage(widget.avatarUrl!)
                                  : null,
                              child: widget.avatarUrl == null ||
                                      widget.avatarUrl!.isEmpty
                                  ? Text(
                                      _avatarInitial,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.displayName ?? widget.username!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    '@${widget.username!}',
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
}
