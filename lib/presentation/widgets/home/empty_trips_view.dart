import 'package:flutter/material.dart';

/// Empty state widget when no trips are available
class EmptyTripsView extends StatelessWidget {
  final bool isLoggedIn;
  final VoidCallback? onLoginPressed;

  const EmptyTripsView({
    super.key,
    required this.isLoggedIn,
    this.onLoginPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isLoggedIn ? Icons.explore_off : Icons.public_off,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            isLoggedIn ? 'No trips yet' : 'No public trips available',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            isLoggedIn
                ? 'Create your first trip to get started!'
                : 'Check back later or login to create your own trips',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          if (!isLoggedIn && onLoginPressed != null) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onLoginPressed,
              icon: const Icon(Icons.login),
              label: const Text('Login / Register'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
