import 'package:book_store/core/utils/extensions/theme_extension.dart';
import 'package:book_store/features/settings/controllers/settings_controller.dart';
import 'package:book_store/features/settings/screens/about_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsScreen extends GetView<SettingsController> {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('ቅንብሮች')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: [
            // ---- Appearance ----
            _buildSectionHeader('ገጽታ'),
            _buildThemeSwitch(context, colorScheme),
            const SizedBox(height: 24),

            // ---- Reading Preferences ----
            _buildSectionHeader('የንባብ ምርጫዎች'),
            _buildReadingSettings(context),
            const SizedBox(height: 24),

            // ---- Audio Settings ----
            _buildSectionHeader('የድምጽ ቅንብሮች'),
            _buildAudioSettings(context),
            const SizedBox(height: 24),

            // ---- Library Preferences ----
            _buildSectionHeader('ቤተ-መጻሕፍት'),
            _buildLibrarySettings(context),
            const SizedBox(height: 24),

            // ---- Notifications ----
            _buildSectionHeader('ማሳወቂያዎች'),
            _buildNotificationSettings(context),
            const SizedBox(height: 24),

            // ---- Data Management ----
            _buildSectionHeader('የመረጃ አስተዳደር'),
            _buildDataManagement(context),
            const SizedBox(height: 24),

            // ---- About ----
            _buildSectionHeader('ስለ መተግበሪያው'),
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
          title: const Text('ጨለማ ገጽታ'),
          subtitle: Text(
            controller.themeMode.value == ThemeMode.dark
                ? 'ጨለማ ገጽታ በርቷል'
                : 'ብሩህ ገጽታ በርቷል',
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
            title: const Text('የፊደል መጠን ለገጾች'),
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
              title: const Text('በራሱ ማንሸራተት (Auto-Scroll)'),
              subtitle: const Text('ገጾችን በራሱ ያንሸራትት'),
              value: controller.autoScroll.value,
              onChanged: controller.toggleAutoScroll,
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
            title: const Text('የድምጽ ማጫወቻ ፍጥነት'),
            subtitle: Obx(() => Text('${controller.defaultSpeed.value}x')),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _showSpeedDialog(),
          ),
          const Divider(height: 0, indent: 60),
          // Auto move to next chapter when the next clicks because one chapter has only one audio
          Obx(
            () => SwitchListTile(
              secondary: Icon(Icons.skip_next_rounded, color: colors.primary),
              title: const Text('ቀጣዩን ምዕራፍ በራሱ አጫውት'),
              subtitle: const Text('ቀጣዩን ምዕራፍ በራሱ ያጫውታል'),
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
              title: const Text('ከኢንተርኔት ውጭ (Offline)'),
              subtitle: const Text('የወረዱትን ብቻ አሳይ'),
              value: controller.offlineMode.value,
              onChanged: controller.toggleOfflineMode,
            ),
          ),
          const Divider(height: 0, indent: 60),
          Obx(
            () => SwitchListTile(
              secondary: Icon(Icons.download_rounded, color: colors.primary),
              title: const Text('በራሱ አውርድ'),
              subtitle: const Text('አዳዲስ ምዕራፎችን በራሱ ያወርዳል'),
              value: controller.autoDownload.value,
              onChanged: controller.toggleAutoDownload,
            ),
          ),
          const Divider(height: 0, indent: 60),
          ListTile(
            leading: Icon(Icons.storage_rounded, color: colors.primary),
            title: const Text('ማከማቻ'),
            subtitle: const Text('የወረዱትን ያስተዳድሩ'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _showStorageDialog(),
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
              title: const Text('አዳዲስ መጻሕፍት'),
              subtitle: const Text('አዳዲስ መጻሕፍት ሲጫኑ አሳውቀኝ'),
              value: controller.notifyNewBooks.value,
              onChanged: controller.toggleNotifyNewBooks,
            ),
          ),
          const Divider(height: 0, indent: 60),
          Obx(
            () => SwitchListTile(
              secondary: Icon(Icons.update_rounded, color: colors.primary),
              title: const Text('ማሻሻያዎች'),
              subtitle: const Text('ማሻሻያዎች ሲኖሩ አሳውቀኝ'),
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
            title: const Text('የንባብ ሂደትን ሰርዝ'),
            subtitle: const Text('የሁሉንም መጻሕፍት እና ምዕራፎች የንባብ ሂደት ያጠፋል።'),
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
        title: const Text('ስለዚህ መተግበሪያ'),
        subtitle: const Text('Version 1.0.0'),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () => Get.to(() => const AboutScreen()),
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
        title: const Text('የፊደል መጠን'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(
              () => Slider(
                value: controller.fontSizeSlider.value,
                min: 0.8,
                max: 1.8,
                divisions: 10,
                label: '${(controller.fontSizeSlider.value * 100).round()}%',
                onChanged: controller.updateFontSize,
              ),
            ),
            Obx(
              () => Text(
                'የናሙና ጽሑፍ መጠን: ${(controller.fontSizeSlider.value * 100).round()}%',
                style: TextStyle(
                  fontSize: 14 * controller.fontSizeSlider.value,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('እሺ')),
        ],
      ),
    );
  }

  void _showSpeedDialog() {
    const speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
    Get.dialog(
      AlertDialog(
        title: const Text('የመጫወቻ ፍጥነት'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: speeds.map((speed) {
              return ListTile(
                title: Text('${speed}x'),
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
        title: const Text('ማከማቻ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              leading: Icon(Icons.sd_storage_rounded),
              title: Text('ያገለገለ ማከማቻ'),
              subtitle: Text('245 MB'),
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.delete_forever_rounded, color: colors.error),
              title: const Text('የወረዱትን በሙሉ አጥፋ'),
              onTap: () {
                Get.back();
                controller.clearDownloads();
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('ዝጋ')),
        ],
      ),
    );
  }
}
