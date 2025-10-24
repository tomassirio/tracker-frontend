import 'package:flutter/material.dart';

/// Password input field with visibility toggle
class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final bool isLogin;
  final TextEditingController? compareController;

  const PasswordField({
    super.key,
    required this.controller,
    this.label = 'Password',
    this.isLogin = true,
    this.compareController,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      decoration: InputDecoration(
        labelText: widget.label,
        prefixIcon: Icon(
          widget.label == 'Password' ? Icons.lock : Icons.lock_outline,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      obscureText: _obscurePassword,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        if (!widget.isLogin && value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        if (widget.compareController != null &&
            value != widget.compareController!.text) {
          return 'Passwords do not match';
        }
        return null;
      },
    );
  }
}

