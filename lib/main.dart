import 'package:flutter/material.dart';
import 'package:tracker_frontend/core/theme/wanderer_theme.dart';
import 'package:tracker_frontend/presentation/screens/initial_screen.dart';
import 'package:tracker_frontend/data/services/trip_update_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize WorkManager for background updates
  await TripUpdateManager.initialize();
  
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
