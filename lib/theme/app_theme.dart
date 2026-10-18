import 'package:flutter/material.dart';


// ---------- Paleta OFIX ----------
class OfixColors {
  // Los nombres originales se conservan: las pantallas actuales los usan.
  static const Color primary = Color(0xFF0D6EFD);
  static const Color darkBlue = Color(0xFF153677);

  static const Color background = Color(0xFFF5F8FC);
  static const Color white = Color(0xFFFFFFFF);

  static const Color textPrimary = Color(0xFF172033);
  static const Color textSecondary = Color(0xFF6B7280);

  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFDC2626);

  // Nuevos: bordes y fondos suaves para chips, iconos y tarjetas
  static const Color border = Color(0xFFE3E9F2);
  static const Color primarySoft = Color(0xFFE8F0FE);
  static const Color successSoft = Color(0xFFDCFCE7);
  static const Color warningSoft = Color(0xFFFEF3C7);
  static const Color errorSoft = Color(0xFFFEE2E2);
}

// ---------- Tema global ----------
class OfixTheme {
  // Radio estándar de campos y botones
  static const double _radius = 12;

  static ThemeData get theme {
    // Estilos de texto base; luego se les aplica la fuente Inter
    const baseText = TextTheme(
      headlineLarge: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w800,
        color: OfixColors.darkBlue,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        color: OfixColors.darkBlue,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: OfixColors.darkBlue,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
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
      labelLarge: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: OfixColors.background,

      colorScheme: ColorScheme.fromSeed(
        seedColor: OfixColors.primary,
        brightness: Brightness.light,
      ).copyWith(
        primary: OfixColors.primary,
        surface: OfixColors.white,
      ),

      // Inter se incluye como archivo local
      // mientras no exista, Flutter usa la fuente por defecto sin fallar

      fontFamily: 'Inter',
      textTheme: baseText,

      // Barra superior blanca, sin sombra ni tinte
      appBarTheme: AppBarTheme(
        backgroundColor: OfixColors.white,
        foregroundColor: OfixColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: OfixColors.darkBlue,
        ),
      ),

      // Tarjetas: blancas, borde fino, sin sombra
      cardTheme: CardThemeData(
        color: OfixColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: OfixColors.border),
        ),
      ),

      // Campos de texto: fondo blanco y borde suave
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: OfixColors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: const BorderSide(color: OfixColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: const BorderSide(color: OfixColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide:
              const BorderSide(color: OfixColors.primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: const BorderSide(color: OfixColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: const BorderSide(color: OfixColors.error, width: 1.6),
        ),
      ),

      // Botones (mismo ancho completo que ya usaban las pantallas)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: OfixColors.primary,
          foregroundColor: OfixColors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radius),
          ),
          elevation: 0,
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: OfixColors.primary,
          foregroundColor: OfixColors.white,
          minimumSize: const Size(0, 52),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radius),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: OfixColors.primary,
          minimumSize: const Size(double.infinity, 52),
          side: const BorderSide(color: OfixColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radius),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: OfixColors.primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      // Barra de navegación inferior (celular)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: OfixColors.white,
        surfaceTintColor: Colors.transparent,
        indicatorColor: OfixColors.primarySoft,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final activo = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: activo ? FontWeight.w700 : FontWeight.w500,
            color: activo ? OfixColors.primary : OfixColors.textSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final activo = states.contains(WidgetState.selected);
          return IconThemeData(
            color: activo ? OfixColors.primary : OfixColors.textSecondary,
          );
        }),
      ),

      // Diálogos y avisos con esquinas redondeadas
      dialogTheme: DialogThemeData(
        backgroundColor: OfixColors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: OfixColors.border,
        thickness: 1,
      ),
    );
  }
}