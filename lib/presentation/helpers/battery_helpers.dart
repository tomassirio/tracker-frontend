import 'package:flutter/material.dart';

/// Shared battery icon and color helpers used by timeline, info window, etc.
class BatteryHelpers {
  /// Returns the appropriate battery icon based on battery level
  static IconData getBatteryIcon(int battery) {
    if (battery >= 90) return Icons.battery_full;
    if (battery >= 70) return Icons.battery_6_bar;
    if (battery >= 50) return Icons.battery_5_bar;
    if (battery >= 30) return Icons.battery_3_bar;
    if (battery >= 20) return Icons.battery_2_bar;
    return Icons.battery_1_bar;
  }

  /// Returns the appropriate color based on battery level
  static Color getBatteryColor(int battery) {
    if (battery >= 50) return Colors.green;
    if (battery >= 20) return Colors.orange;
    return Colors.red;
  }
}
