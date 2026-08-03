import 'package:book_store/core/utils/extensions/theme_extension.dart';
import 'package:book_store/features/settings/controllers/settings_controller.dart';
import 'package:book_store/features/settings/screens/about_screen.dart';
import 'package:book_store/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:book_store/core/constants/app_texts.dart';

class SettingsScreen extends GetView<SettingsController> {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text(AppTexts.settingsAppBarTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: [
            // ---- Appearance ----
            _buildSectionHeader(AppTexts.settingsSectionAppearance),
            _buildThemeSwitch(context, colorScheme),
            const SizedBox(height: 24),

            // ---- Reading Preferences ----
            _buildSectionHeader(AppTexts.settingsSectionReading),
            _buildReadingSettings(context),
            const SizedBox(height: 24),

            // ---- Audio Settings ----
            _buildSectionHeader(AppTexts.settingsSectionAudio),
            _buildAudioSettings(context),
            const SizedBox(height: 24),

            // ---- Library Preferences ----
            _buildSectionHeader(AppTexts.settingsSectionLibrary),
            _buildLibrarySettings(context),
            const SizedBox(height: 24),

            // ---- Notifications ----
            _buildSectionHeader(AppTexts.settingsSectionNotifications),
            _buildNotificationSettings(context),
            const SizedBox(height: 24),

            // ---- Data Management ----
            _buildSectionHeader(AppTexts.settingsSectionDataManagement),
            _buildDataManagement(context),
            const SizedBox(height: 24),

            // ---- Feedback ----
            _buildSectionHeader(AppTexts.feedbackSectionTitle),
            _buildFeedback(context),
            const SizedBox(height: 24),

            // ---- About ----
            _buildSectionHeader(AppTexts.settingsSectionAbout),
            _buildAbout(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // -- Theme Switch --
  Widget _buildThemeSwitch(BuildContext context, ColorScheme colorScheme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Obx(() {
        return SwitchListTile(
          title: const Text(AppTexts.settingsDarkThemeTitle),
          subtitle: Text(
            controller.themeMode.value == ThemeMode.dark
                ? AppTexts.settingsDarkThemeActive
                : AppTexts.settingsLightThemeActive,
          ),
          value: controller.themeMode.value == ThemeMode.dark,
          onChanged: (value) {
            controller.setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
          },
          activeThumbColor: colorScheme.primary,
          secondary: Icon(
            controller.themeMode.value == ThemeMode.dark
                ? Icons.dark_mode_rounded
                : Icons.light_mode_rounded,
            color: controller.themeMode.value == ThemeMode.dark
                ? context.sacred.gold
                : colorScheme.primary,
          ),
        );
      }),
    );
  }

  // -- Reading Settings --
  Widget _buildReadingSettings(BuildContext context) {
    final colors = context.colorScheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          // a text size for text based books
          ListTile(
            leading: Icon(Icons.text_fields_rounded, color: colors.primary),
            title: const Text(AppTexts.settingsFontSizeForPagesTitle),
            subtitle: Obx(() => Text(controller.fontSize.value)),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _showFontSizeDialog(),
          ),
          const Divider(height: 0, indent: 60),
          // Auto Scroll/next page for chapter reader
          Obx(
            () => SwitchListTile(
              secondary: Icon(
                Icons.auto_awesome_rounded,
                color: colors.primary,
              ),
              title: const Text(AppTexts.settingsAutoScrollTitle),
              subtitle: const Text(AppTexts.settingsAutoScrollSubtitle),
              value: controller.autoScroll.value,
              onChanged: controller.toggleAutoScroll,
            ),
          ),
          const Divider(height: 0, indent: 60),
          Obx(
            () => SwitchListTile(
              secondary: Icon(
                controller.imagePageVerticalScroll.value
                    ? Icons.swipe_down_alt_rounded
                    : Icons.swipe_left_alt_rounded,
                color: colors.primary,
              ),
              title: const Text(AppTexts.settingsPageScrollDirectionTitle),
              subtitle: Text(
                controller.imagePageVerticalScroll.value
                    ? AppTexts.settingsPageScrollVertical
                    : AppTexts.settingsPageScrollHorizontal,
              ),
              value: controller.imagePageVerticalScroll.value,
              onChanged: controller.toggleImagePageVerticalScroll,
            ),
          ),
        ],
      ),
    );
  }

  // -- Audio Settings --
  Widget _buildAudioSettings(BuildContext context) {
    final colors = context.colorScheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.speed_rounded, color: colors.primary),
            title: const Text(AppTexts.settingsAudioPlayerSpeedTitle),
            subtitle: Obx(() => Text(AppTexts.playerSpeedValue(controller.defaultSpeed.value))),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _showSpeedDialog(),
          ),
          const Divider(height: 0, indent: 60),
          // Auto move to next chapter when the next clicks because one chapter has only one audio
          Obx(
            () => SwitchListTile(
              secondary: Icon(Icons.skip_next_rounded, color: colors.primary),
              title: const Text(AppTexts.settingsAutoPlayNextTitle),
              subtitle: const Text(AppTexts.settingsAutoPlayNextSubtitle),
              value: controller.autoPlayNext.value,
              onChanged: controller.toggleAutoPlayNext,
            ),
          ),
        ],
      ),
    );
  }

  // -- Library Settings --
  Widget _buildLibrarySettings(BuildContext context) {
    final colors = context.colorScheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Obx(
            () => SwitchListTile(
              secondary: Icon(
                Icons.offline_bolt_rounded,
                color: colors.primary,
              ),
              title: const Text(AppTexts.settingsOfflineModeTitle),
              subtitle: const Text(AppTexts.settingsOfflineModeSubtitle),
              value: controller.offlineMode.value,
              onChanged: controller.toggleOfflineMode,
            ),
          ),
          const Divider(height: 0, indent: 60),
          Obx(
            () => SwitchListTile(
              secondary: Icon(Icons.download_rounded, color: colors.primary),
              title: const Text(AppTexts.settingsAutoDownloadTitle),
              subtitle: const Text(AppTexts.settingsAutoDownloadSubtitle),
              value: controller.autoDownload.value,
              onChanged: controller.toggleAutoDownload,
            ),
          ),
          const Divider(height: 0, indent: 60),
          ListTile(
            leading: Icon(Icons.storage_rounded, color: colors.primary),
            title: const Text(AppTexts.settingsStorageTitle),
            subtitle: const Text(AppTexts.settingsStorageSubtitle),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => Get.toNamed(Routes.downloads),
          ),
        ],
      ),
    );
  }

  // -- Notifications --
  Widget _buildNotificationSettings(BuildContext context) {
    final colors = context.colorScheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Obx(
            () => SwitchListTile(
              secondary: Icon(Icons.book_rounded, color: colors.primary),
              title: const Text(AppTexts.settingsNotifyNewBooksTitle),
              subtitle: const Text(AppTexts.settingsNotifyNewBooksSubtitle),
              value: controller.notifyNewBooks.value,
              onChanged: controller.toggleNotifyNewBooks,
            ),
          ),
          const Divider(height: 0, indent: 60),
          Obx(
            () => SwitchListTile(
              secondary: Icon(Icons.update_rounded, color: colors.primary),
              title: const Text(AppTexts.settingsNotifyUpdatesTitle),
              subtitle: const Text(AppTexts.settingsNotifyUpdatesSubtitle),
              value: controller.notifyUpdates.value,
              onChanged: controller.toggleNotifyUpdates,
            ),
          ),
        ],
      ),
    );
  }

  // -- Data Management --
  Widget _buildDataManagement(BuildContext context) {
    final colors = context.colorScheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.restore_page_rounded, color: colors.error),
            title: const Text(AppTexts.settingsResetReadingProgressTitle),
            subtitle: const Text(AppTexts.settingsResetReadingProgressSubtitle),
            onTap: controller.resetReadingProgress,
            trailing: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
    );
  }

  // -- About --
  Widget _buildAbout(BuildContext context) {
    final colors = context.colorScheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Icon(Icons.info_outline_rounded, color: colors.primary),
        title: const Text(AppTexts.settingsAboutAppTitle),
        subtitle: const Text(AppTexts.settingsAppVersion),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () => Get.to(() => const AboutScreen()),
      ),
    );
  }

  // -- Feedback --
  Widget _buildFeedback(BuildContext context) {
    final colors = context.colorScheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Icon(Icons.feedback_outlined, color: colors.primary),
        title: const Text(AppTexts.feedbackButtonTitle),
        subtitle: const Text(AppTexts.feedbackButtonSubtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: controller.sendFeedback,
      ),
    );
  }

  // -- Section Header --
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Theme.of(Get.context!).colorScheme.onSurfaceVariant,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // ===== DIALOGS =====

  void _showFontSizeDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text(AppTexts.settingsFontSizeDialogTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(
              () => Slider(
                value: controller.fontSizeSlider.value,
                min: 0.8,
                max: 1.8,
                divisions: 10,
                label: AppTexts.settingsFontSizePercent((controller.fontSizeSlider.value * 100).round()),
                onChanged: controller.updateFontSize,
              ),
            ),
            Obx(
              () => Text(
                AppTexts.settingsFontSizeSample((controller.fontSizeSlider.value * 100).round()),
                style: TextStyle(
                  fontSize: 14 * controller.fontSizeSlider.value,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text(AppTexts.dialogOk)),
        ],
      ),
    );
  }

  void _showSpeedDialog() {
    const speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
    Get.dialog(
      AlertDialog(
        title: const Text(AppTexts.settingsPlayerSpeedDialogTitle),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: speeds.map((speed) {
              return ListTile(
                title: Text(AppTexts.playerSpeedValue(speed)),
                trailing: Obx(
                  () => Radio<double>(
                    value: speed,
                    groupValue: controller.defaultSpeed.value,
                    onChanged: (value) {
                      if (value != null) controller.setDefaultSpeed(value);
                      Get.back();
                    },
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _showStorageDialog() {
    final colors = Theme.of(Get.context!).colorScheme;
    Get.dialog(
      AlertDialog(
        title: const Text(AppTexts.settingsStorageTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              leading: Icon(Icons.sd_storage_rounded),
              title: const Text(AppTexts.settingsUsedStorageTitle),
              subtitle: const Text(AppTexts.settingsStorageUsed),
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.delete_forever_rounded, color: colors.error),
              title: const Text(AppTexts.settingsClearAllDownloadsTitle),
              onTap: () {
                Get.back();
                controller.clearDownloads();
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text(AppTexts.dialogClose)),
        ],
      ),
    );
  }
}
