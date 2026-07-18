import 'package:book_store/core/theme/app_theme.dart';
import 'package:book_store/ui/screens/splash_screen.dart';
import 'package:book_store/ui/widgets/audio_player_overlay.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Book Reader',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
      builder: (context, child) {
        if (child == null) return const SizedBox.shrink();
        return AudioPlayerOverlay(child: child);
      },
    );
  }
}
