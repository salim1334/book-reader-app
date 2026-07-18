import 'package:book_store/features/chapter_reader/controllers/chapter_reader_controller.dart';
import 'package:book_store/features/chapter_reader/controllers/image_reader_controller.dart';
import 'package:book_store/features/chapter_reader/controllers/text_reader_controller.dart';
import 'package:get/get.dart';

class ChapterReaderBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ChapterReaderController());
    Get.put(TextReaderController());
    Get.put(ImageReaderController());
  }
}
