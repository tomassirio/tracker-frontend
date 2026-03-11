import 'package:flutter/material.dart';

/// Username input field with validation
class UsernameField extends StatelessWidget {
  final TextEditingController controller;
  final bool isLogin;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;

  const UsernameField({
    super.key,
    required this.controller,
    required this.isLogin,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: 'Username',
        prefixIcon: const Icon(Icons.person),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      textCapitalization: TextCapitalization.none,
      textInputAction: textInputAction ?? TextInputAction.next,
      onFieldSubmitted: onFieldSubmitted,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter your username';
        }
        if (!isLogin && value.trim().length < 3) {
          return 'Username must be at least 3 characters';
        }
        return null;
      },
    );
  }
}
