import 'package:book_store/features/downloads/screens/downloads_screen.dart';
import 'package:book_store/features/home/screens/home_screen.dart';
import 'package:book_store/features/main_navigation/controllers/main_navigation_controller.dart';
import 'package:book_store/features/settings/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainNavigationScreen extends GetView<MainNavigationController> {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const screens = [
      HomeScreen(),
      DownloadsScreen(),
      SettingsScreen(),
    ];

    return Obx(
      () => Scaffold(
        body: IndexedStack(
          index: controller.selectedIndex.value,
          children: screens,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: controller.selectedIndex.value,
          onTap: controller.changeTab,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.download), label: 'Downloads'),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
          ],
        ),
      ),
    );
  }
}
