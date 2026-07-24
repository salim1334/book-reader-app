import 'package:book_store/data/repositories/settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_routes.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settingsController = Get.find<SettingsRepository>();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "ኢስላማዊ መጽሐፍት",
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "የኡስታዝ ሳዳት ከማል ኪታቦች ኮሌክሽን",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          _HeaderButton(
            icon: Icons.search,
            onTap: () => Get.toNamed(Routes.search),
          ),

          const SizedBox(width: 12),

          _HeaderButton(
            icon: settingsController.themeMode.value == ThemeMode.dark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            onTap: () => settingsController.setThemeMode(settingsController.themeMode.value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light),
          ),
        ],
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: SizedBox(width: 50, height: 50, child: Icon(icon)),
      ),
    );
  }
}
