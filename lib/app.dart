import 'package:book_store/common/widgets/audio_player_overlay.dart';
import 'package:book_store/core/theme/app_theme.dart';
import 'package:book_store/data/repositories/settings_repository.dart';
import 'package:book_store/routes/app_pages.dart';
import 'package:book_store/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsRepository>();
    return Obx(() {
      return GetMaterialApp(
        title: 'Book Reader',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: settings.themeMode.value,
        initialRoute: Routes.splash,
        getPages: AppPages.pages,
        builder: (context, child) {
          if (child == null) return const SizedBox.shrink();

          return AudioPlayerOverlay(child: child);
        },
      );
    });
  }
}
