import 'package:flutter/material.dart';
import 'package:tracker_frontend/presentation/widgets/auth/auth_header.dart';
import 'package:tracker_frontend/presentation/widgets/auth/auth_mode_toggle.dart';
import 'package:tracker_frontend/presentation/widgets/auth/auth_submit_button.dart';
import 'package:tracker_frontend/presentation/widgets/auth/email_field.dart';
import 'package:tracker_frontend/presentation/widgets/auth/error_message.dart';
import 'package:tracker_frontend/presentation/widgets/auth/password_field.dart';
import 'package:tracker_frontend/presentation/widgets/auth/username_field.dart';

/// Main authentication form widget
class AuthForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final bool isLogin;
  final bool isLoading;
  final String? errorMessage;
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final VoidCallback onSubmit;
  final VoidCallback onToggleMode;
  final VoidCallback onForgotPassword;

  const AuthForm({
    super.key,
    required this.formKey,
    required this.isLogin,
    required this.isLoading,
    this.errorMessage,
    required this.usernameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.onSubmit,
    required this.onToggleMode,
    required this.onForgotPassword,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthHeader(isLogin: isLogin),
              const SizedBox(height: 32),

              // Username field
              UsernameField(
                controller: usernameController,
                isLogin: isLogin,
              ),
              const SizedBox(height: 16),

              // Email field (only for registration)
              if (!isLogin) ...[
                EmailField(controller: emailController),
                const SizedBox(height: 16),
              ],

              // Password field
              PasswordField(
                controller: passwordController,
                isLogin: isLogin,
              ),
              const SizedBox(height: 16),

              // Confirm password field (only for registration)
              if (!isLogin) ...[
                PasswordField(
                  controller: confirmPasswordController,
                  label: 'Confirm Password',
                  isLogin: false,
                  compareController: passwordController,
                ),
                const SizedBox(height: 16),
              ],

              // Forgot password button (only for login)
              if (isLogin)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: isLoading ? null : onForgotPassword,
                    child: const Text('Forgot Password?'),
                  ),
                ),

              // Error message
              if (errorMessage != null) ...[
                const SizedBox(height: 8),
                ErrorMessage(message: errorMessage!),
              ],

              const SizedBox(height: 24),

              // Submit button
              AuthSubmitButton(
                isLogin: isLogin,
                isLoading: isLoading,
                onPressed: onSubmit,
              ),

              const SizedBox(height: 16),

              // Toggle login/register
              AuthModeToggle(
                isLogin: isLogin,
                isLoading: isLoading,
                onToggle: onToggleMode,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

