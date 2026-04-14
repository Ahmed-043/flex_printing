import 'package:flutter/material.dart';

class AppTheme {
  // Dummy light colors (change later)
  static const _lightPrimary = Color(0xFFFFFFFF);
  static const _lightSecondary = Color(0xFFED2024);
  static const _lightText = Color(0xFFFFFFFF);
  static const _lightDark = Color(0xFF000000);
  static const _lightGrey = Color(0xFFD7D8D8);
  static const _lightError = Color(0xFFED2024);



  // Dummy dark colors (change later)
  static const _darkPrimary = Color(0xFFFFFFFF);
  static const _darkSecondary = Color(0xFFED2024);
  static const _darkText = Color(0xFFFFFFFF);
  static const _darkDark = Color(0xFF000000);
  static const _darkGrey = Color(0xFFD7D8D8);
  static const _darkError = Color(0xFFED2024);

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: _lightPrimary,
      brightness: Brightness.light,
    ).copyWith(
      primary: _lightPrimary,
      secondary: _lightSecondary,
      surface: _lightPrimary,
      secondaryContainer: _lightDark,
      surfaceContainer: _lightGrey,
      // "Text" colors in Material come from on* colors:
      onSurface: _lightText,
      onPrimary: _lightDark,
      onSecondary: _lightText,
      error: _lightError,

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

      scaffoldBackgroundColor: _lightPrimary,
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: MaterialStateProperty.all(_lightDark.withOpacity(0.2)),
        trackColor: MaterialStateProperty.all(_lightDark.withOpacity(0.3)),
        radius: const Radius.circular(8),
        thickness: MaterialStateProperty.all(8),
      ),
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
      surface: _darkPrimary,
      secondaryContainer: _darkDark,
      surfaceContainer: _darkGrey,

      onSurface: _darkText,
      onPrimary: _darkDark,
      onSecondary: _darkText,
      error: _darkError,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,

      textTheme: ThemeData.dark().textTheme.apply(
        bodyColor: _darkText,
        displayColor: _darkText,
      ),

      scaffoldBackgroundColor: _darkPrimary,
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: MaterialStateProperty.all(_darkDark.withOpacity(0.2)),
        trackColor: MaterialStateProperty.all(_darkDark.withOpacity(0.3)),
        radius: const Radius.circular(8),
        thickness: MaterialStateProperty.all(8),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: _darkText,
        elevation: 0,
      ),
    );
  }
}