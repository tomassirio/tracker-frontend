import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:tracker_frontend/core/theme/wanderer_theme.dart';
import 'package:tracker_frontend/core/services/background_update_manager.dart';
import 'package:tracker_frontend/core/services/navigation_service.dart';
import 'package:tracker_frontend/core/services/notification_service.dart';
import 'package:tracker_frontend/presentation/screens/initial_screen.dart';
import 'package:tracker_frontend/presentation/screens/auth_screen.dart';
import 'package:tracker_frontend/presentation/screens/verify_email_screen.dart';

/// Global route observer for detecting when screens become visible again
final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Android-only services
  if (!kIsWeb && Platform.isAndroid) {
    await BackgroundUpdateManager().initialize();
    final notificationService = NotificationService();
    await notificationService.initialize();
    await notificationService.requestPermission();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wanderer',
      debugShowCheckedModeBanner: false,
      theme: WandererTheme.lightTheme(),
      navigatorKey: NavigationService().navigatorKey,
      navigatorObservers: [routeObserver],
      home: const InitialScreen(),
      routes: {
        '/auth': (context) => const AuthScreen(),
        '/verify-email': (context) => const VerifyEmailScreen(),
      },
    );
  }
}
