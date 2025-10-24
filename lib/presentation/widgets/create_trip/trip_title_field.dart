import 'package:flutter/material.dart';

/// Text field for trip title input
class TripTitleField extends StatelessWidget {
  final TextEditingController controller;

  const TripTitleField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'Trip Title *',
        hintText: 'e.g., European Summer Adventure',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.title),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a title';
        }
        return null;
      },
    );
  }
}
