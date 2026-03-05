import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wanderer_frontend/presentation/widgets/auth/forgot_password_form.dart';

void main() {
  group('ForgotPasswordForm', () {
    late TextEditingController emailController;

    setUp(() {
      emailController = TextEditingController();
    });

    tearDown(() {
      emailController.dispose();
    });

    Widget buildWidget({
      bool isLoading = false,
      String? errorMessage,
      bool passwordResetSent = false,
      VoidCallback? onSubmit,
      VoidCallback? onBackToLogin,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ForgotPasswordForm(
              emailController: emailController,
              isLoading: isLoading,
              errorMessage: errorMessage,
              passwordResetSent: passwordResetSent,
              onSubmit: onSubmit ?? () {},
              onBackToLogin: onBackToLogin ?? () {},
            ),
          ),
        ),
      );
    }

    group('email form view', () {
      testWidgets('displays reset password header', (tester) async {
        await tester.pumpWidget(buildWidget());

        expect(find.text('Reset Password'), findsOneWidget);
      });

      testWidgets('displays instructional text', (tester) async {
        await tester.pumpWidget(buildWidget());

        expect(
          find.textContaining('Enter your email address'),
          findsOneWidget,
        );
      });

      testWidgets('displays email input field', (tester) async {
        await tester.pumpWidget(buildWidget());

        expect(find.byType(TextFormField), findsOneWidget);
        expect(find.text('Email'), findsOneWidget);
      });

      testWidgets('displays send reset link button', (tester) async {
        await tester.pumpWidget(buildWidget());

        expect(find.text('Send Reset Link'), findsOneWidget);
      });

      testWidgets('displays back to login button', (tester) async {
        await tester.pumpWidget(buildWidget());

        expect(find.text('Back to Login'), findsOneWidget);
      });

      testWidgets('calls onSubmit when button is pressed', (tester) async {
        var submitCalled = false;
        await tester.pumpWidget(buildWidget(
          onSubmit: () => submitCalled = true,
        ));

        await tester.tap(find.text('Send Reset Link'));
        await tester.pumpAndSettle();

        expect(submitCalled, isTrue);
      });

      testWidgets('calls onBackToLogin when back button is pressed',
          (tester) async {
        var backCalled = false;
        await tester.pumpWidget(buildWidget(
          onBackToLogin: () => backCalled = true,
        ));

        await tester.tap(find.text('Back to Login'));
        await tester.pumpAndSettle();

        expect(backCalled, isTrue);
      });

      testWidgets('shows loading indicator when isLoading is true',
          (tester) async {
        await tester.pumpWidget(buildWidget(isLoading: true));
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Send Reset Link'), findsNothing);
      });

      testWidgets('disables button when isLoading is true', (tester) async {
        var submitCalled = false;
        await tester.pumpWidget(buildWidget(
          isLoading: true,
          onSubmit: () => submitCalled = true,
        ));
        await tester.pump();

        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        expect(submitCalled, isFalse);
      });

      testWidgets('displays error message when provided', (tester) async {
        await tester.pumpWidget(buildWidget(
          errorMessage: 'Please enter a valid email',
        ));

        expect(find.text('Please enter a valid email'), findsOneWidget);
      });

      testWidgets('email input accepts text', (tester) async {
        await tester.pumpWidget(buildWidget());

        await tester.enterText(
          find.byType(TextFormField),
          'test@example.com',
        );
        await tester.pump();

        expect(emailController.text, 'test@example.com');
      });
    });

    group('success view', () {
      testWidgets('shows success view when passwordResetSent is true',
          (tester) async {
        emailController.text = 'test@example.com';
        await tester.pumpWidget(buildWidget(passwordResetSent: true));

        expect(find.text('Check your email'), findsOneWidget);
        expect(
          find.textContaining('test@example.com'),
          findsOneWidget,
        );
      });

      testWidgets('success view shows back to login button', (tester) async {
        await tester.pumpWidget(buildWidget(passwordResetSent: true));

        expect(find.text('Back to Login'), findsOneWidget);
      });

      testWidgets(
          'success view calls onBackToLogin when back button is pressed',
          (tester) async {
        var backCalled = false;
        await tester.pumpWidget(buildWidget(
          passwordResetSent: true,
          onBackToLogin: () => backCalled = true,
        ));

        await tester.tap(find.text('Back to Login'));
        await tester.pumpAndSettle();

        expect(backCalled, isTrue);
      });

      testWidgets('success view shows email icon', (tester) async {
        await tester.pumpWidget(buildWidget(passwordResetSent: true));

        expect(
          find.byIcon(Icons.mark_email_unread_outlined),
          findsOneWidget,
        );
      });

      testWidgets('success view does not show email input', (tester) async {
        await tester.pumpWidget(buildWidget(passwordResetSent: true));

        expect(find.byType(TextFormField), findsNothing);
      });
    });
  });
}
