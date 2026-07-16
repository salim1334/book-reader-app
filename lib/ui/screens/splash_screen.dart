import 'package:book_store/data/repositories/settings_repository.dart';
import 'package:book_store/ui/screens/main_navigation.dart';
import 'package:book_store/ui/screens/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final settings = Get.find<SettingsRepository>();
    final hasSeenOnboarding = await settings.hasSeenOnboarding();

    if (!mounted) return;

    final route = MaterialPageRoute(
      builder: (_) => hasSeenOnboarding
          ? const MainNavigation()
          : const OnboardingScreen(),
    );
    Navigator.of(context).pushReplacement(route);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

