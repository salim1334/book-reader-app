import 'package:book_store/common/utils/snackbar_helper.dart';
import 'package:book_store/data/repositories/book_repository.dart';
import 'package:book_store/data/repositories/settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsController extends GetxController {
  final SettingsRepository _settingsRepository = Get.find<SettingsRepository>();
  final BookRepository _bookRepository = Get.find<BookRepository>();

  Rx<ThemeMode> get themeMode => _settingsRepository.themeMode;

  Future<void> setThemeMode(ThemeMode mode) async {
    await _settingsRepository.setThemeMode(mode);
  }

  Future<void> resetOnboarding() async {
    await _settingsRepository.clearCache();
    SnackbarHelper.show('Cache cleared. Restart app to see onboarding.');
  }

  Future<void> resetReadingProgress() async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Reset reading progress?'),
        content: const Text('This will reset all reading progress and cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _bookRepository.clearReadingProgress();
      SnackbarHelper.show('Reading progress reset.');
    }
  }

  Future<void> clearDownloads() async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Clear downloads?'),
        content: const Text('This will delete all downloaded books and media files.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _bookRepository.clearContent();
      SnackbarHelper.show('Downloaded content cleared.');
    }
  }
}
