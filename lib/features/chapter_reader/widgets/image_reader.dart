import 'dart:io';

import 'package:book_store/core/constants/app_enums.dart';
import 'package:book_store/data/repositories/settings_repository.dart';
import 'package:book_store/features/chapter_reader/controllers/chapter_reader_controller.dart';
import 'package:book_store/features/chapter_reader/controllers/image_reader_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

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
        return const Center(child: Text('ለዚህ ምዕራፍ ምንም የወረደ ምስል የለም'));
      }

      final total = media.images.length;

      final current = controller.currentPageIndex.value.clamp(0, total - 1) + 1;

      final immersive = chapterController.isImmersiveMode.value;

      final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

      final settings = Get.find<SettingsRepository>();
      final scrollDirection = settings.imagePageVerticalScroll.value
          ? Axis.vertical
          : Axis.horizontal;

      return Stack(
        fit: StackFit.expand,

        children: [
          PhotoViewGallery.builder(
            pageController: controller.pageController,

            itemCount: total,

            scrollDirection: scrollDirection,

            reverse:
                controller.chapterReader.book.swipeDirection ==
                SwipeDirection.rtl,

            scrollPhysics: controller.isZoomed
                ? const NeverScrollableScrollPhysics()
                : const PageScrollPhysics(),

            onPageChanged: controller.onPageChanged,

            builder: (context, index) {
              final pageController = controller.getPhotoController(index);

              return PhotoViewGalleryPageOptions(
                imageProvider: FileImage(File(media.images[index])),

                controller: pageController.photoController,

                scaleStateController: pageController.scaleController,

                initialScale: isLandscape
                    ? PhotoViewComputedScale.contained * 2.5
                    : PhotoViewComputedScale.contained,

                minScale: PhotoViewComputedScale.contained,

                maxScale: PhotoViewComputedScale.covered * 4,
              );
            },
          ),

          if (scrollDirection == Axis.horizontal)
            ...[
              if (controller.currentPageIndex.value > 0)
                Positioned(
                  left: 12,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: IconButton(
                      iconSize: 40,
                      onPressed: controller.previousPage,
                      icon: const Icon(
                        Icons.chevron_left,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              if (controller.currentPageIndex.value < total - 1)
                Positioned(
                  right: 12,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: IconButton(
                      iconSize: 40,
                      onPressed: controller.nextPage,
                      icon: const Icon(
                        Icons.chevron_right,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
            ]
          else
            ...[
              if (controller.currentPageIndex.value > 0)
                Positioned(
                  top: 60,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: IconButton(
                      iconSize: 40,
                      onPressed: controller.previousPage,
                      icon: const Icon(
                        Icons.keyboard_arrow_up,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              if (controller.currentPageIndex.value < total - 1)
                Positioned(
                  bottom: 60,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: IconButton(
                      iconSize: 40,
                      onPressed: controller.nextPage,
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
            ],

          if (!immersive)
            Positioned(
              bottom: 12,

              left: 0,

              right: 0,

              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,

                    vertical: 6,
                  ),

                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surface.withValues(alpha: 0.85),

                    borderRadius: BorderRadius.circular(16),
                  ),

                  child: Text(
                    '$current / $total',

                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.8),
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
