import 'package:book_store/common/utils/snackbar_helper.dart';
import 'package:book_store/core/services/notification_service.dart';
import 'package:book_store/core/utils/device/device_utils.dart';
import 'package:book_store/data/repositories/book_repository.dart';
import 'package:book_store/data/repositories/settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:book_store/core/constants/app_texts.dart';

class SettingsController extends GetxController {
  final SettingsRepository _settingsRepository = Get.find<SettingsRepository>();
  final BookRepository _bookRepository = Get.find<BookRepository>();

  // ─── Theme ────────────────────────────────────────────────
  Rx<ThemeMode> get themeMode => _settingsRepository.themeMode;

  // ─── Reading Preferences ──────────────────────────────────
  RxString get fontSize => _settingsRepository.fontSize;
  RxDouble get fontSizeSlider => _settingsRepository.fontSizeScale;
  RxBool get autoScroll => _settingsRepository.autoScroll;
  RxBool get imagePageVerticalScroll => _settingsRepository.imagePageVerticalScroll;

  // ─── Audio Settings ──────────────────────────────────────
  RxDouble get defaultSpeed => _settingsRepository.defaultSpeed;
  RxBool get autoPlayNext => _settingsRepository.autoPlayNext;

  // ─── Library Preferences ─────────────────────────────────
  RxBool get offlineMode => _settingsRepository.offlineMode;
  RxBool get autoDownload => _settingsRepository.autoDownload;

  // ─── Notifications ────────────────────────────────────────
  RxBool get notifyNewBooks => _settingsRepository.notifyNewBooks;
  RxBool get notifyUpdates => _settingsRepository.notifyUpdates;

  // ─── Theme ─────────────────────────────────────────────────
  Future<void> setThemeMode(ThemeMode mode) async {
    await _settingsRepository.setThemeMode(mode);
  }

  // ─── Reading Preferences ──────────────────────────────────
  void setFontSize(String value) => _settingsRepository.setFontSize(value);

  void updateFontSize(double value) {
    _settingsRepository.setFontSizeSlider(value);
    // Update the human‑readable label based on slider value
    if (value < 1.0) {
      setFontSize(AppTexts.settingsFontSizeSmall);
    } else if (value < 1.4) {
      setFontSize(AppTexts.settingsFontSizeMedium);
    } else {
      setFontSize(AppTexts.settingsFontSizeLarge);
    }
  }

  void toggleAutoScroll(bool value) => _settingsRepository.setAutoScroll(value);

  void toggleImagePageVerticalScroll(bool value) =>
      _settingsRepository.setImagePageVerticalScroll(value);

  // ─── Audio Settings ──────────────────────────────────────
  void setDefaultSpeed(double value) => _settingsRepository.setDefaultSpeed(value);

  void toggleAutoPlayNext(bool value) => _settingsRepository.setAutoPlayNext(value);

  // ─── Library Preferences ─────────────────────────────────
  void toggleOfflineMode(bool value) => _settingsRepository.setOfflineMode(value);

  void toggleAutoDownload(bool value) => _settingsRepository.setAutoDownload(value);

  // ─── Notifications ────────────────────────────────────────
  void toggleNotifyNewBooks(bool value) => _settingsRepository.setNotifyNewBooks(value);

  void toggleNotifyUpdates(bool value) => _settingsRepository.setNotifyUpdates(value);

  Future<void> testNotification() async {
    final notificationService = Get.find<NotificationService>();
    await notificationService.showTestNotification();
    SnackbarHelper.show(AppTexts.settingsTestNotificationMessage);
  }

  // ─── Data Management ─────────────────────────────────────

  Future<void> resetReadingProgress() async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text(AppTexts.settingsResetProgressDialogTitle),
        content: const Text(
          AppTexts.settingsResetProgressDialogBody,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text(AppTexts.dialogCancel),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text(AppTexts.dialogReset),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _bookRepository.clearReadingProgress();
      SnackbarHelper.show(AppTexts.settingsReadingProgressResetMessage);
    }
  }

  Future<void> clearDownloads() async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text(AppTexts.settingsClearDownloadsDialogTitle),
        content: const Text(
          AppTexts.settingsClearDownloadsDialogBody,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text(AppTexts.dialogCancel),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text(AppTexts.dialogClear),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _bookRepository.clearContent();
      SnackbarHelper.show(AppTexts.settingsDownloadsClearedMessage);
    }
  }

  Future<void> clearCache() async {
    await _settingsRepository.clearCache();
    SnackbarHelper.show(AppTexts.settingsCacheClearedMessage);
  }

  // ─── Feedback ─────────────────────────────────────────────
  Future<void> sendFeedback() async {
    try {
      final opened = await DeviceUtils.openFeedbackEmail();
      if (!opened) {
        SnackbarHelper.show(AppTexts.feedbackNoEmailApp);
      }
    } catch (_) {
      SnackbarHelper.show(AppTexts.feedbackOpenError);
    }
  }
}
