import 'dart:io';

import 'package:book_store/data/local/models/book_local_models.dart';
import 'package:book_store/features/chapter_reader/controllers/image_reader_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ImageReader extends GetView<ImageReaderController> {
  const ImageReader({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final media = controller.media.value;
      if (media == null || media.images.isEmpty) {
        return const Center(
          child: Text('No downloaded images for this chapter.'),
        );
      }

      return PageView.builder(
        controller: controller.pageController,
        reverse: controller.chapterReader.book.swipeDirection.pageViewReverse,
        itemCount: media.images.length,
        itemBuilder: (context, index) {
          return InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: Image.file(
              File(media.images[index]),
              fit: BoxFit.contain,
            ),
          );
        },
      );
    });
  }
}
