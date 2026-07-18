import 'package:book_store/features/downloads/controllers/downloads_controller.dart';
import 'package:book_store/features/home/controllers/home_controller.dart';
import 'package:book_store/features/main_navigation/controllers/main_navigation_controller.dart';
import 'package:book_store/features/settings/controllers/settings_controller.dart';
import 'package:get/get.dart';

class MainNavigationBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(MainNavigationController());
    Get.put(HomeController());
    Get.put(DownloadsController());
    Get.put(SettingsController());
  }
}
