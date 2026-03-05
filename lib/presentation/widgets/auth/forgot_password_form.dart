import 'package:flutter/material.dart';
import 'package:wanderer_frontend/presentation/widgets/auth/error_message.dart';
import 'package:wanderer_frontend/presentation/widgets/common/wanderer_logo.dart';

/// Form widget for the forgot password flow.
///
/// Shows either the email input form or a success confirmation
/// depending on the [passwordResetSent] state.
class ForgotPasswordForm extends StatelessWidget {
  final TextEditingController emailController;
  final bool isLoading;
  final String? errorMessage;
  final bool passwordResetSent;
  final VoidCallback onSubmit;
  final VoidCallback onBackToLogin;

  const ForgotPasswordForm({
    super.key,
    required this.emailController,
    required this.isLoading,
    this.errorMessage,
    required this.passwordResetSent,
    required this.onSubmit,
    required this.onBackToLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: passwordResetSent
            ? _buildSuccessView(context)
            : _buildEmailForm(context),
      ),
    );
  }

  Widget _buildEmailForm(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const WandererLogo(size: 80),
        const SizedBox(height: 16),
        Text(
          'Reset Password',
          style: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Enter your email address and we\'ll send you a link to reset your password.',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        TextFormField(
          controller: emailController,
          decoration: InputDecoration(
            labelText: 'Email',
            prefixIcon: const Icon(Icons.email),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          keyboardType: TextInputType.emailAddress,
          textCapitalization: TextCapitalization.none,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => isLoading ? null : onSubmit(),
        ),
        if (errorMessage != null) ...[
          const SizedBox(height: 8),
          ErrorMessage(message: errorMessage!),
        ],
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: isLoading ? null : onSubmit,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Send Reset Link', style: TextStyle(fontSize: 16)),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: isLoading ? null : onBackToLogin,
          child: const Text('Back to Login'),
        ),
      ],
    );
  }

  Widget _buildSuccessView(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.mark_email_unread_outlined,
          size: 64,
          color: Colors.blueAccent,
        ),
        const SizedBox(height: 24),
        const Text(
          'Check your email',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Text(
          'If an account with ${emailController.text.trim()} exists, '
          'we\'ve sent a password reset link. Check your inbox and follow '
          'the instructions to reset your password.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 15),
        ),
        const SizedBox(height: 24),
        TextButton(
          onPressed: onBackToLogin,
          child: const Text('Back to Login'),
        ),
      ],
    );
  }
}
