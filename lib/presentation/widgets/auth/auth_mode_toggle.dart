import 'package:flutter/material.dart';

/// Toggle between login and registration modes
class AuthModeToggle extends StatelessWidget {
  final bool isLogin;
  final bool isLoading;
  final VoidCallback onToggle;

  const AuthModeToggle({
    super.key,
    required this.isLogin,
    required this.isLoading,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            isLogin ? "Don't have an account? " : 'Already have an account? ',
            style: TextStyle(color: Colors.grey[600]),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        TextButton(
          onPressed: isLoading ? null : onToggle,
          child: Text(
            isLogin ? 'Sign Up' : 'Sign In',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
