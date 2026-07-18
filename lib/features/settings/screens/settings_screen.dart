import 'package:book_store/features/settings/controllers/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsScreen extends GetView<SettingsController> {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          Obx(() {
            return ListTile(
              title: const Text('Theme'),
              subtitle: Text(controller.themeMode.value.name),
              trailing: DropdownButton<ThemeMode>(
                value: controller.themeMode.value,
                onChanged: (mode) {
                  if (mode != null) {
                    controller.setThemeMode(mode);
                  }
                },
                items: ThemeMode.values
                    .map(
                      (mode) => DropdownMenuItem(
                        value: mode,
                        child: Text(mode.name),
                      ),
                    )
                    .toList(),
              ),
            );
          }),
          ListTile(
            title: const Text('Reset onboarding'),
            leading: const Icon(Icons.restart_alt),
            onTap: controller.resetOnboarding,
          ),
          ListTile(
            title: const Text('Reset reading progress'),
            subtitle: const Text('Clear all book and chapter reading progress.'),
            leading: const Icon(Icons.restore_page, color: Colors.orange),
            onTap: controller.resetReadingProgress,
          ),
          ListTile(
            title: const Text('Clear downloaded books'),
            subtitle: const Text('Remove all downloaded books, chapters, and media.'),
            leading: const Icon(Icons.delete_sweep),
            onTap: controller.clearDownloads,
          ),
          const AboutListTile(
            icon: Icon(Icons.info),
            applicationName: 'Book Reader',
            applicationVersion: '1.0.0',
            applicationLegalese: 'Book Store Mobile Reader',
          ),
        ],
      ),
    );
  }
}
