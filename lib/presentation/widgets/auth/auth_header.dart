import 'package:flutter/material.dart';
import 'package:tracker_frontend/presentation/widgets/common/wanderer_logo.dart';

/// Header widget with logo and title for auth screen
class AuthHeader extends StatelessWidget {
  final bool isLogin;

  const AuthHeader({super.key, required this.isLogin});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const WandererLogo(size: 80),
        const SizedBox(height: 16),
        Text(
          isLogin ? 'Welcome Back!' : 'Create Account',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          isLogin
              ? 'Sign in to continue your journey'
              : 'Sign up to start tracking your adventures',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
