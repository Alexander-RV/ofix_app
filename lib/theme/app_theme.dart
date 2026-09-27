import 'package:flutter/material.dart';

class OfixColors {
  static const Color primary = Color(0xFF0D6EFD);
  static const Color darkBlue = Color(0xFF153677);

  static const Color background = Color(0xFFF5F8FC);
  static const Color white = Color(0xFFFFFFFF);

  static const Color textPrimary = Color(0xFF172033);
  static const Color textSecondary = Color(0xFF6B7280);

  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFDC2626);
}



class OfixTheme {
  static ThemeData theme = ThemeData(
    useMaterial3: true,

    scaffoldBackgroundColor: OfixColors.background,

    colorScheme: ColorScheme.fromSeed(
      seedColor: OfixColors.primary,
      brightness: Brightness.light,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: OfixColors.white,
      foregroundColor: OfixColors.textPrimary,
      elevation: 0,
    ),

    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.bold,
        color: OfixColors.textPrimary,
      ),

      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: OfixColors.textPrimary,
      ),

      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: OfixColors.textPrimary,
      ),

      bodyLarge: TextStyle(
        fontSize: 16,
        color: OfixColors.textPrimary,
      ),

      bodyMedium: TextStyle(
        fontSize: 14,
        color: OfixColors.textSecondary,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: OfixColors.primary,
        foregroundColor: OfixColors.white,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: OfixColors.primary,
        minimumSize: const Size(double.infinity, 52),
        side: const BorderSide(
          color: OfixColors.primary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  );
}