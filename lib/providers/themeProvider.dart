import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';

enum AppThemeMode { light, dark }

class ThemeNotifier extends StateNotifier<AppThemeMode> {
  final GetStorage _box;

  ThemeNotifier(this._box) : super(AppThemeMode.light) {
    _loadTheme();
  }

  void _loadTheme() {
    final modeStr = _box.read<String>('theme_mode') ?? 'light';
    state = modeStr == 'dark' ? AppThemeMode.dark : AppThemeMode.light;
  }

  Future<void> toggleTheme() async {
    state = state == AppThemeMode.light ? AppThemeMode.dark : AppThemeMode.light;
    await _box.write('theme_mode', state.name);
  }
}

final getStorageProvider = Provider<GetStorage>((ref) => GetStorage());

final themeProvider = StateNotifierProvider.autoDispose<ThemeNotifier, AppThemeMode>((ref) {
  final box = ref.watch(getStorageProvider);
  return ThemeNotifier(box);
});