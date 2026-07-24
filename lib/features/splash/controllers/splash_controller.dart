import 'package:book_store/data/repositories/settings_repository.dart';
import 'package:book_store/routes/app_routes.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {
  final SettingsRepository _settingsRepository = Get.find<SettingsRepository>();

  @override
  Future<void> onReady() async {
    super.onReady();
    // wait for a short duration to show the splash screen
    await Future.delayed(const Duration(seconds: 3));
    await navigateNext();
  }

  Future<void> navigateNext() async {
    final hasSeenOnboarding = await _settingsRepository.hasSeenOnboarding();
    Get.offAllNamed(hasSeenOnboarding ? Routes.main : Routes.onboarding);
  }
}
