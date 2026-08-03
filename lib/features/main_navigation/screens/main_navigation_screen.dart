import 'package:book_store/features/favorites/screens/favorites_screen.dart';
import 'package:book_store/features/home/screens/home_screen.dart';
import 'package:book_store/features/main_navigation/controllers/main_navigation_controller.dart';
import 'package:book_store/features/main_navigation/widgets/bottom_navigation_bar.dart';
import 'package:book_store/features/settings/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:book_store/core/constants/app_texts.dart';

import '../models/main_navigation.dart';

class MainNavigationScreen extends GetView<MainNavigationController> {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const screens = [HomeScreen(), FavoritesScreen(), SettingsScreen()];

    final navItems = [
      NavItem(icon: Icons.home_rounded, label: AppTexts.navHome),
      NavItem(icon: Icons.bookmark_rounded, label: AppTexts.navFavorites),
      NavItem(icon: Icons.settings_rounded, label: AppTexts.navSettings),
    ];

    return Obx(
      () => Scaffold(
        body: IndexedStack(
          index: controller.selectedIndex.value,
          children: screens,
        ),
        bottomNavigationBar: CustomBottomNavBar(
          currentIndex: controller.selectedIndex.value,
          onTap: controller.changeTab,
          items: navItems,
        ),
      ),
    );
  }
}
