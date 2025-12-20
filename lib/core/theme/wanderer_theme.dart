import 'package:flutter/material.dart';

/// Wanderer App Theme Configuration
/// Inspired by modern trip tracking UI with warm orange/amber tones
class WandererTheme {
  // Primary Colors
  static const Color primaryOrange = Color(0xFFE07830); // Main orange
  static const Color primaryOrangeLight =
      Color(0xFFF5A623); // Light orange/amber
  static const Color primaryOrangeDark = Color(0xFFD35400); // Dark orange

  // Background Colors
  static const Color backgroundLight = Color(0xFFFAF9F7); // Warm off-white
  static const Color backgroundCard = Color(0xFFFFFFFF); // Pure white for cards
  static const Color backgroundDark = Color(0xFF2C2C2C); // Dark mode background

  // Text Colors
  static const Color textPrimary = Color(0xFF1A1A1A); // Almost black
  static const Color textSecondary = Color(0xFF666666); // Gray
  static const Color textTertiary = Color(0xFF999999); // Light gray
  static const Color textOnPrimary = Color(0xFFFFFFFF); // White text on orange

  // Status Colors
  static const Color statusCreated = Color(0xFF4CAF50); // Green
  static const Color statusInProgress = Color(0xFFFF9800); // Orange
  static const Color statusCompleted = Color(0xFF2196F3); // Blue
  static const Color statusCancelled = Color(0xFFF44336); // Red

  // Map Colors
  static const Color mapRouteColor = Color(0xFF0088FF); // Blue route line
  static const Color mapMarkerStart = Color(0xFF4CAF50); // Green
  static const Color mapMarkerEnd = Color(0xFFF44336); // Red
  static const Color mapMarkerWaypoint = Color(0xFFFF9800); // Orange

  // Timeline Colors
  static const Color timelineConnector = Color(0xFFE0E0E0);
  static const Color timelineNodeActive = Color(0xFFE07830);
  static const Color timelineNodeCompleted = Color(0xFF4CAF50);

  // Shadows
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.12),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  /// Get the light theme
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryOrange,
        primary: primaryOrange,
        secondary: primaryOrangeLight,
        surface: backgroundLight,
        background: backgroundLight,
        onPrimary: textOnPrimary,
        onSecondary: textOnPrimary,
        onSurface: textPrimary,
        onBackground: textPrimary,
      ),
      scaffoldBackgroundColor: backgroundLight,
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundCard,
        foregroundColor: textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryOrange,
          foregroundColor: textOnPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryOrange,
          side: const BorderSide(color: primaryOrange),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryOrange,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: backgroundLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryOrange, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: backgroundLight,
        selectedColor: primaryOrange.withOpacity(0.2),
        labelStyle: const TextStyle(fontSize: 12),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.grey.shade200,
        thickness: 1,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryOrange,
        foregroundColor: textOnPrimary,
      ),
    );
  }

  /// Status chip decoration
  static BoxDecoration statusChipDecoration(String status) {
    Color bgColor;
    switch (status.toUpperCase()) {
      case 'CREATED':
        bgColor = statusCreated.withOpacity(0.15);
        break;
      case 'IN_PROGRESS':
        bgColor = statusInProgress.withOpacity(0.15);
        break;
      case 'COMPLETED':
        bgColor = statusCompleted.withOpacity(0.15);
        break;
      case 'CANCELLED':
        bgColor = statusCancelled.withOpacity(0.15);
        break;
      default:
        bgColor = Colors.grey.withOpacity(0.15);
    }
    return BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(12),
    );
  }

  /// Get status text color
  static Color statusTextColor(String status) {
    switch (status.toUpperCase()) {
      case 'CREATED':
        return statusCreated;
      case 'IN_PROGRESS':
        return statusInProgress;
      case 'COMPLETED':
        return statusCompleted;
      case 'CANCELLED':
        return statusCancelled;
      default:
        return textSecondary;
    }
  }
}
