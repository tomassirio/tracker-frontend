import 'package:flutter/material.dart';
import 'package:tracker_frontend/data/repositories/auth_repository.dart';
import 'package:tracker_frontend/presentation/helpers/ui_helpers.dart';
import 'package:tracker_frontend/presentation/widgets/auth/auth_form.dart';

/// Authentication screen for login and registration
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final AuthRepository _repository = AuthRepository();
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // State
  bool _isLogin = true;
  bool _isLoading = false;
  String? _errorMessage;
  bool _registrationPending = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isLogin) {
        await _repository.login(
          _usernameController.text.trim(),
          _passwordController.text,
        );

        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } else {
        await _repository.register(
          _usernameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text,
        );

        if (mounted) {
          setState(() {
            _registrationPending = true;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      UiHelpers.showErrorMessage(context, 'Please enter your email address');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _repository.requestPasswordReset(email);

      if (mounted) {
        UiHelpers.showSuccessMessage(
          context,
          'Password reset email sent! Check your inbox.',
        );
      }
    } catch (e) {
      if (mounted) {
        UiHelpers.showErrorMessage(
          context,
          'Error: ${e.toString().replaceAll('Exception: ', '')}',
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _toggleMode() {
    setState(() {
      _isLogin = !_isLogin;
      _errorMessage = null;
      _registrationPending = false;
      _formKey.currentState?.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 450),
                child: _registrationPending
                    ? _buildRegistrationPendingView()
                    : AuthForm(
                        formKey: _formKey,
                        isLogin: _isLogin,
                        isLoading: _isLoading,
                        errorMessage: _errorMessage,
                        usernameController: _usernameController,
                        emailController: _emailController,
                        passwordController: _passwordController,
                        confirmPasswordController: _confirmPasswordController,
                        onSubmit: _submit,
                        onToggleMode: _toggleMode,
                        onForgotPassword: _forgotPassword,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegistrationPendingView() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.mark_email_unread_outlined,
                size: 64, color: Colors.blueAccent),
            const SizedBox(height: 24),
            const Text(
              'Check your email',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'We sent a verification link to ${_emailController.text.trim()}. '
              'Click the link in the email to complete your registration.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () {
                setState(() {
                  _registrationPending = false;
                  _isLogin = true;
                  _errorMessage = null;
                  _formKey.currentState?.reset();
                });
              },
              child: const Text('Back to Login'),
            ),
          ],
        ),
      ),
    );
  }
}
