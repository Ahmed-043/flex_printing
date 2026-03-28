import 'package:flutter/material.dart';

class AppTheme {
  // Dummy light colors (change later)
  static const _lightPrimary = Color(0xFFFFFFFF);
  static const _lightSecondary = Color(0xFFED2024);
  static const _lightText = Color(0xFFFFFFFF);

  // Dummy dark colors (change later)
  static const _darkPrimary = Color(0xFFFFFFFF);
  static const _darkSecondary = Color(0xFFED2024);
  static const _darkText = Color(0xFFFFFFFF);

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: _lightPrimary,
      brightness: Brightness.light,
    ).copyWith(
      primary: _lightPrimary,
      secondary: _lightSecondary,

      // "Text" colors in Material come from on* colors:
      onSurface: _lightText,
      onBackground: _lightText,
      onPrimary: _lightText,
      onSecondary: _lightText,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,

      // Applies default text color across Text widgets
      textTheme: ThemeData.light().textTheme.apply(
        bodyColor: _lightText,
        displayColor: _lightText,
      ),

      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: _lightText,
        elevation: 0,
      ),
    );
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: _darkPrimary,
      brightness: Brightness.dark,
    ).copyWith(
      primary: _darkPrimary,
      secondary: _darkSecondary,

      onSurface: _darkText,
      onBackground: _darkText,
      onPrimary: _darkText,
      onSecondary: _darkText,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,

      textTheme: ThemeData.dark().textTheme.apply(
        bodyColor: _darkText,
        displayColor: _darkText,
      ),

      scaffoldBackgroundColor: const Color(0xFF0B1220),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: _darkText,
        elevation: 0,
      ),
    );
  }
}