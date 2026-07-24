import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:book_store/data/local/daos/settings_dao.dart';

class SettingsRepository extends GetxService {
  final SettingsDao _dao;

  SettingsRepository({SettingsDao? dao}) : _dao = dao ?? SettingsDao();

  // ─── Keys ────────────────────────────────────────────
  static const String _keyOnboarding = 'has_seen_onboarding';
  static const String _keyTheme = 'theme_mode';

  // Reading preferences
  static const String _keyFontSize = 'font_size';
  static const String _keyFontSizeSlider = 'font_size_slider';
  static const String _keyAutoScroll = 'auto_scroll';

  // Audio settings
  static const String _keyDefaultSpeed = 'default_speed';
  static const String _keyAutoPlayNext = 'auto_play_next';

  // Library preferences
  static const String _keyOfflineMode = 'offline_mode';
  static const String _keyAutoDownload = 'auto_download';

  // Notifications
  static const String _keyNotifyNewBooks = 'notify_new_books';
  static const String _keyNotifyUpdates = 'notify_updates';

  // ─── Theme ────────────────────────────────────────────
  final Rx<ThemeMode> themeMode = ThemeMode.system.obs;
  final RxString fontSize = 'Medium'.obs;
  final RxDouble fontSizeScale = 1.0.obs;
  final RxBool autoScroll = true.obs;
  final RxDouble defaultSpeed = 1.0.obs;
  final RxBool autoPlayNext = true.obs;
  final RxBool offlineMode = false.obs;
  final RxBool autoDownload = false.obs;
  final RxBool notifyNewBooks = true.obs;
  final RxBool notifyUpdates = true.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _loadSettings();
  }

  Future<void> _loadSettings() async {
    await _loadTheme();
    fontSize.value = await getFontSize();
    fontSizeScale.value = await getFontSizeSlider();
    autoScroll.value = await getAutoScroll();
    defaultSpeed.value = await getDefaultSpeed();
    autoPlayNext.value = await getAutoPlayNext();
    offlineMode.value = await getOfflineMode();
    autoDownload.value = await getAutoDownload();
    notifyNewBooks.value = await getNotifyNewBooks();
    notifyUpdates.value = await getNotifyUpdates();
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

  // ─── Reading Preferences ──────────────────────────────
  Future<String> getFontSize() async =>
      (await _dao.getString(_keyFontSize)) ?? 'Medium';
  Future<void> setFontSize(String value) async {
    fontSize.value = value;
    await _dao.setString(_keyFontSize, value);
  }

  Future<double> getFontSizeSlider() async =>
      (await _dao.getDouble(_keyFontSizeSlider)) ?? 1.0;
  Future<void> setFontSizeSlider(double value) async {
    fontSizeScale.value = value;
    await _dao.setDouble(_keyFontSizeSlider, value);
  }

  Future<bool> getAutoScroll() async =>
      await _dao.getBool(_keyAutoScroll, defaultValue: true);
  Future<void> setAutoScroll(bool value) async {
    autoScroll.value = value;
    await _dao.setBool(_keyAutoScroll, value);
  }

  // ─── Audio Settings ──────────────────────────────────
  Future<double> getDefaultSpeed() async =>
      (await _dao.getDouble(_keyDefaultSpeed)) ?? 1.0;
  Future<void> setDefaultSpeed(double value) async {
    defaultSpeed.value = value;
    await _dao.setDouble(_keyDefaultSpeed, value);
  }

  Future<bool> getAutoPlayNext() async =>
      await _dao.getBool(_keyAutoPlayNext, defaultValue: true);
  Future<void> setAutoPlayNext(bool value) async {
    autoPlayNext.value = value;
    await _dao.setBool(_keyAutoPlayNext, value);
  }

  // ─── Library Preferences ─────────────────────────────
  Future<bool> getOfflineMode() async =>
      await _dao.getBool(_keyOfflineMode, defaultValue: false);
  Future<void> setOfflineMode(bool value) async {
    offlineMode.value = value;
    await _dao.setBool(_keyOfflineMode, value);
  }

  Future<bool> getAutoDownload() async =>
      await _dao.getBool(_keyAutoDownload, defaultValue: false);
  Future<void> setAutoDownload(bool value) async {
    autoDownload.value = value;
    await _dao.setBool(_keyAutoDownload, value);
  }

  // ─── Notifications ──────────────────────────────────
  Future<bool> getNotifyNewBooks() async =>
      await _dao.getBool(_keyNotifyNewBooks, defaultValue: true);
  Future<void> setNotifyNewBooks(bool value) async {
    notifyNewBooks.value = value;
    await _dao.setBool(_keyNotifyNewBooks, value);
  }

  Future<bool> getNotifyUpdates() async =>
      await _dao.getBool(_keyNotifyUpdates, defaultValue: true);
  Future<void> setNotifyUpdates(bool value) async {
    notifyUpdates.value = value;
    await _dao.setBool(_keyNotifyUpdates, value);
  }

  // ─── Clear All Settings ─────────────────────────────
  Future<void> clearCache() async {
    await _dao.setBool(_keyOnboarding, false);
    await _dao.setString(_keyTheme, 'system');
    themeMode.value = ThemeMode.system;
    Get.changeThemeMode(ThemeMode.system);

    await _dao.setString(_keyFontSize, 'Medium');
    fontSize.value = 'Medium';
    await _dao.setDouble(_keyFontSizeSlider, 1.0);
    fontSizeScale.value = 1.0;
    await _dao.setBool(_keyAutoScroll, true);
    autoScroll.value = true;

    await _dao.setDouble(_keyDefaultSpeed, 1.0);
    defaultSpeed.value = 1.0;
    await _dao.setBool(_keyAutoPlayNext, true);
    autoPlayNext.value = true;

    await _dao.setBool(_keyOfflineMode, false);
    offlineMode.value = false;
    await _dao.setBool(_keyAutoDownload, false);
    autoDownload.value = false;

    await _dao.setBool(_keyNotifyNewBooks, true);
    notifyNewBooks.value = true;
    await _dao.setBool(_keyNotifyUpdates, true);
    notifyUpdates.value = true;
  }
}
