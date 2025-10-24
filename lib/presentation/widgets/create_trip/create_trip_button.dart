import 'package:flutter/material.dart';

/// Submit button for creating a trip
class CreateTripButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const CreateTripButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.add),
      label: Text(isLoading ? 'Creating...' : 'Create Trip'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(16),
      ),
    );
  }
}

