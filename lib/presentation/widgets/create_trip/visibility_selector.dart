import 'package:flutter/material.dart' hide Visibility;
import 'package:tracker_frontend/core/constants/enums.dart';

/// Visibility selector widget with segmented buttons
class VisibilitySelector extends StatelessWidget {
  final Visibility selectedVisibility;
  final ValueChanged<Visibility> onVisibilityChanged;

  const VisibilitySelector({
    super.key,
    required this.selectedVisibility,
    required this.onVisibilityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Visibility',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SegmentedButton<Visibility>(
          segments: const [
            ButtonSegment(
              value: Visibility.private,
              label: Text('Private'),
              icon: Icon(Icons.lock),
            ),
            ButtonSegment(
              value: Visibility.protected,
              label: Text('Protected'),
              icon: Icon(Icons.group),
            ),
            ButtonSegment(
              value: Visibility.public,
              label: Text('Public'),
              icon: Icon(Icons.public),
            ),
          ],
          selected: {selectedVisibility},
          onSelectionChanged: (Set<Visibility> newSelection) {
            onVisibilityChanged(newSelection.first);
          },
        ),
        const SizedBox(height: 8),
        Text(
          _getVisibilityDescription(selectedVisibility),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  String _getVisibilityDescription(Visibility visibility) {
    switch (visibility) {
      case Visibility.private:
        return 'Only you can see this trip';
      case Visibility.protected:
        return 'Followers or users with a shared link can view';
      case Visibility.public:
        return 'Everyone can see this trip';
    }
  }
}
