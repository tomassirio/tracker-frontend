import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:tracker_frontend/core/theme/wanderer_theme.dart';
import 'package:tracker_frontend/core/services/background_update_manager.dart';
import 'package:tracker_frontend/presentation/screens/initial_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize background update manager for Android only
  if (!kIsWeb && Platform.isAndroid) {
    await BackgroundUpdateManager().initialize();
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
      home: const InitialScreen(),
    );
  }
}
