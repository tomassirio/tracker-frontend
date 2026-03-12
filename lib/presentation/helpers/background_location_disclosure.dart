import 'package:flutter/material.dart';

/// Helper for showing the prominent background location disclosure
/// required by Google Play for apps using ACCESS_BACKGROUND_LOCATION.
///
/// Google requires a prominent in-app disclosure that:
/// 1. Is within the app itself (not only in the app description)
/// 2. Appears before the system permission prompt
/// 3. Describes what data is collected and how it is used
/// 4. Explains the relationship between data collection and the app's feature
/// 5. Provides user affordance to consent (and decline)
class BackgroundLocationDisclosure {
  /// Shows a prominent disclosure dialog explaining why the app needs
  /// background location access. Returns `true` if the user consents.
  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.location_on, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Background Location Access',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Wanderer collects your location data to enable automatic '
                'trip tracking even when the app is closed or not in use.',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 12),
              Text(
                'How your location is used:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              _DisclosureBullet(
                icon: Icons.route,
                text:
                    'Your GPS coordinates are periodically sent to update your '
                    'trip timeline so friends and family can follow your journey.',
              ),
              SizedBox(height: 6),
              _DisclosureBullet(
                icon: Icons.battery_saver,
                text:
                    'Battery level is included with each update to help your '
                    'followers know your device status.',
              ),
              SizedBox(height: 6),
              _DisclosureBullet(
                icon: Icons.schedule,
                text:
                    'Updates are sent at the interval you choose in trip '
                    'settings (e.g., every 15 minutes).',
              ),
              SizedBox(height: 6),
              _DisclosureBullet(
                icon: Icons.stop_circle_outlined,
                text:
                    'Background location collection stops automatically when '
                    'you pause or finish your trip.',
              ),
              SizedBox(height: 16),
              Text(
                'You can disable automatic updates at any time from the trip '
                'settings. If you decline, you can still send manual location '
                'updates while the app is open.',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No thanks'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Allow'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

/// A bullet point row used in the disclosure dialog.
class _DisclosureBullet extends StatelessWidget {
  final IconData icon;
  final String text;

  const _DisclosureBullet({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 13)),
        ),
      ],
    );
  }
}

