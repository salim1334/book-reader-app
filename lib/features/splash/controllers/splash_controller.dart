import 'package:book_store/core/bindings/app_binding.dart';
import 'package:book_store/data/local/daos/book_dao.dart';
import 'package:book_store/data/local/database_helper.dart';
import 'package:book_store/data/local/services/bundled_content_seeder.dart';
import 'package:book_store/data/repositories/settings_repository.dart';
import 'package:book_store/routes/app_routes.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {
  final SettingsRepository _settingsRepository = Get.find<SettingsRepository>();

  @override
  Future<void> onReady() async {
    super.onReady();
    final initWork = _initAfterFirstFrame();
    final minDelay = Future.delayed(const Duration(seconds: 3));

    await Future.wait([initWork, minDelay]);
    await navigateNext();
  }

  Future<void> _initAfterFirstFrame() async {
    final db = await DatabaseHelper.instance.database;
    await BundledContentSeeder(BookDao(db)).seedIfNeeded();
    await AppBinding.asyncInit();
  }

  Future<void> navigateNext() async {
    final hasSeenOnboarding = await _settingsRepository.hasSeenOnboarding();
    Get.offAllNamed(hasSeenOnboarding ? Routes.main : Routes.onboarding);
  }
}
