import 'package:book_store/features/favorites/controllers/favorites_controller.dart';
import 'package:get/get.dart';

class MainNavigationController extends GetxController {
  final selectedIndex = 0.obs;
  final FavoritesController favoritesController =
      Get.find<FavoritesController>();

  void changeTab(int index) async {
    // ignore if the selected index is the same as the current index
    if (selectedIndex.value == index) return;
    
    // if (index == 1) {
    //   favoritesController.load();
    // }
    selectedIndex.value = index;
  }
}
