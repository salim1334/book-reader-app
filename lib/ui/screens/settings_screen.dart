import 'package:book_store/data/repositories/book_repository.dart';
import 'package:book_store/data/repositories/settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsRepository>();
    final repository = Get.find<BookRepository>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          Obx(() {
            return ListTile(
              title: const Text('Theme'),
              subtitle: Text(settings.themeMode.value.name),
              trailing: DropdownButton<ThemeMode>(
                value: settings.themeMode.value,
                onChanged: (mode) {
                  if (mode != null) {
                    settings.setThemeMode(mode);
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
            onTap: () async {
              await settings.clearCache();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cache cleared. Restart app to see onboarding.')),
                );
              }
            },
          ),
          ListTile(
            title: const Text('Reset reading progress'),
            subtitle: const Text('Clear all book and chapter reading progress.'),
            leading: const Icon(Icons.restore_page, color: Colors.orange),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Reset reading progress?'),
                  content: const Text('This will reset all reading progress and cannot be undone.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await repository.clearReadingProgress();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Reading progress reset.')),
                  );
                }
              }
            },
          ),
          ListTile(
            title: const Text('Clear downloaded books'),
            subtitle: const Text('Remove all downloaded books, chapters, and media.'),
            leading: const Icon(Icons.delete_sweep),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear downloads?'),
                  content: const Text('This will delete all downloaded books and media files.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await repository.clearContent();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Downloaded content cleared.')),
                  );
                }
              }
            },
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
