import 'package:book_store/features/downloads/controllers/downloads_controller.dart';
import 'package:get/get.dart';

class DownloadsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(DownloadsController());
  }
}
