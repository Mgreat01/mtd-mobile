import 'package:flutter/material.dart';

class AppTheme {
  // Palette partagée
  static const Color primaryLight = Color(0xFFF1F5F9);   // --color-primary
  static const Color primaryDark = Color(0xFF0F172A);    // --color-primary-dark-mode
  static const Color backgroundLight = Colors.white;     // --color-background
  static const Color backgroundDark = Color(0xFF0F172A); // --color-background-dark
  static const Color cardLight = Colors.white;           // --color-card
  static const Color cardDark = Color(0xFF1E293B);       // --color-card-dark
  static const Color borderLight = Color(0xFFD1D5DB);    // --color-border
  static const Color borderDark = Color(0xFF374151);     // --color-border-dark
  static const Color textLight = Color(0xFF6B7280);      // --color-text / gray-500
  static const Color textDark = Color(0xFF9CA3AF);        // --color-text-dark / gray-400
  static const Color primaryDarkAccent = Color(0xFF1D4ED8); // --color-primary-dark (hover)

  static final lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: primaryDarkAccent,
      onPrimary: Colors.white,
      surface: cardLight,
      onSurface: textLight,
      outline: borderLight,
      secondary: primaryLight,
      error: Colors.red,
    ),
    scaffoldBackgroundColor: backgroundLight,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryLight,
      foregroundColor: textLight,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: cardLight,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cardLight,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: borderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryDarkAccent, width: 2),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryDarkAccent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
      ),
    ),

    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: textLight),
      titleMedium: TextStyle(color: textLight, fontWeight: FontWeight.w600),
    ),
  );

  static final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: primaryDarkAccent,
      onPrimary: Colors.white,
      surface: cardDark,
      onSurface: textDark,
      outline: borderDark,
      secondary: primaryDark,
      error: Colors.redAccent,
    ),
    scaffoldBackgroundColor: backgroundDark,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryDark,
      foregroundColor: textDark,
      elevation: 0,
    ),

    cardTheme: CardThemeData(
      color: cardDark,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cardDark,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: borderDark),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: borderDark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryDarkAccent, width: 2),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryDarkAccent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),

    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: textDark),
      titleMedium: TextStyle(color: textDark, fontWeight: FontWeight.w600),
    ),
  );
}