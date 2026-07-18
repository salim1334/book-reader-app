import 'package:book_store/features/book_details/controllers/book_details_controller.dart';
import 'package:get/get.dart';

class BookDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(BookDetailsController());
  }
}
