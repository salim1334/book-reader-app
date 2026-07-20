import 'package:book_store/features/favorites/controllers/favorites_controller.dart';
import 'package:get/get.dart';

class FavoritesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(FavoritesController.new);
  }
}
