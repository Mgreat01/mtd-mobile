// lib/utils/themes/app_theme.dart
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
    colorScheme: ColorScheme.light(
      primary: primaryLight,
      onPrimary: textLight, // texte sur fond primary (ex: header)
      secondary: primaryDarkAccent,
      background: backgroundLight,
      surface: cardLight,
      onBackground: textLight,
      onSurface: textLight, // ← texte sur Card, AppBar, ListTile
      outline: borderLight, // utilisé pour les bordures (ex: TextField)
      error: Colors.red,
    ),
    scaffoldBackgroundColor: backgroundLight,
    appBarTheme: AppBarTheme(
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
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: borderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: primaryDarkAccent, width: 2),
      ),
    ),
    textTheme: Typography.material2021().englishLike.copyWith(
      // On force le gris (pas noir) pour coller au web
      bodyMedium: Typography.material2021().englishLike.bodyMedium?.copyWith(
        color: textLight,
      ),
      titleMedium: Typography.material2021().englishLike.titleMedium?.copyWith(
        color: textLight,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  static final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: primaryDark,
      onPrimary: textDark,
      secondary: primaryDarkAccent,
      background: backgroundDark,
      surface: cardDark,
      onBackground: textDark,
      onSurface: textDark, // ← texte clair sur fond sombre
      outline: borderDark,
      error: Colors.redAccent,
    ),
    scaffoldBackgroundColor: backgroundDark,
    appBarTheme: AppBarTheme(
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
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: borderDark),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: borderDark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: primaryDarkAccent, width: 2),
      ),
    ),
    textTheme: Typography.material2021().englishLike.copyWith(
      bodyMedium: Typography.material2021().englishLike.bodyMedium?.copyWith(
        color: textDark,
      ),
      titleMedium: Typography.material2021().englishLike.titleMedium?.copyWith(
        color: textDark,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}