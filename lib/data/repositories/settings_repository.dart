import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:book_store/data/local/daos/settings_dao.dart';

class SettingsRepository extends GetxService {
  final SettingsDao _dao = SettingsDao();

  static const String _keyOnboarding = 'has_seen_onboarding';
  static const String _keyTheme = 'theme_mode';

  final Rx<ThemeMode> themeMode = ThemeMode.system.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _loadTheme();
  }

  Future<void> _loadTheme() async {
    final stored = await _dao.getString(_keyTheme);
    themeMode.value = switch (stored) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<bool> hasSeenOnboarding() => _dao.getBool(_keyOnboarding);

  Future<void> setOnboardingComplete() => _dao.setBool(_keyOnboarding, true);

  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode.value = mode;
    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await _dao.setString(_keyTheme, value);
    Get.changeThemeMode(mode);
  }

  Future<void> clearCache() async {
    await _dao.setBool(_keyOnboarding, false);
    await _dao.setString(_keyTheme, 'system');
    themeMode.value = ThemeMode.system;
  }
}
