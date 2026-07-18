import 'package:book_store/data/repositories/settings_repository.dart';
import 'package:book_store/routes/app_routes.dart';
import 'package:get/get.dart';

class OnboardingController extends GetxController {
  final SettingsRepository _settingsRepository = Get.find<SettingsRepository>();

  Future<void> completeOnboarding() async {
    await _settingsRepository.setOnboardingComplete();
    Get.offAllNamed(Routes.main);
  }
}
