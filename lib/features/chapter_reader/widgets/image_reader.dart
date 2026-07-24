import 'dart:io';

import 'package:book_store/data/local/models/book_local_models.dart';
import 'package:book_store/features/chapter_reader/controllers/chapter_reader_controller.dart';
import 'package:book_store/features/chapter_reader/controllers/image_reader_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ImageReader extends GetView<ImageReaderController> {
  const ImageReader({super.key});

  @override
  Widget build(BuildContext context) {
    final chapterController = Get.find<ChapterReaderController>();

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

      final total = media.images.length;
      final current = controller.currentPageIndex.value.clamp(0, total - 1) + 1;
      final immersive = chapterController.isImmersiveMode.value;

      return Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: controller.pageController,
            reverse: controller.chapterReader.book.swipeDirection.pageViewReverse,
            itemCount: total,
            onPageChanged: (index) => controller.onPageChanged(index),
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
          ),
          // Subtle page counter, hidden in immersive mode.
          if (!immersive)
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '$current / $total',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }
}
