// lib/providers/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';

enum AppThemeMode { light, dark }

class ThemeNotifier extends StateNotifier<AppThemeMode> {
  ThemeNotifier(this._box) : super(AppThemeMode.light) {
    _loadTheme();
  }

  final GetStorage _box;

  Future<void> _loadTheme() async {
    final modeStr = _box.read<String>('theme_mode') ?? 'light';
    final mode = AppThemeMode.values.firstWhere(
      (e) => e.name == modeStr,
      orElse: () => AppThemeMode.light,
    );
    state = mode;
  }

  Future<void> setTheme(AppThemeMode mode) async {
    state = mode;
    await _box.write('theme_mode', mode.name);
  }

  Future<void> toggleTheme() async {
    final newMode = state == AppThemeMode.light ? AppThemeMode.dark : AppThemeMode.light;
    await setTheme(newMode);
  }
}

// Provider : on injecte GetStorage via ref.watch (meilleure testabilité)
final getStorageProvider = Provider<GetStorage>((ref) {
  // ⚠️ Assure-toi que GetStorage a été initialisé AVANT runApp (voir plus bas)
  return GetStorage();
});

final themeProvider = StateNotifierProvider<ThemeNotifier, AppThemeMode>((ref) {
  final box = ref.watch(getStorageProvider);
  return ThemeNotifier(box);
});