import 'package:flutter/material.dart';

/// Text field for trip description input
class TripDescriptionField extends StatelessWidget {
  final TextEditingController controller;

  const TripDescriptionField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'Description (Optional)',
        hintText: 'Tell us about your trip...',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.description),
      ),
      maxLines: 3,
    );
  }
}
