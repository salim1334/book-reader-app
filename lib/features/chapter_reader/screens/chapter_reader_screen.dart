import 'package:book_store/core/theme/sacred_theme_extension.dart';
import 'package:book_store/core/utils/extensions/theme_extension.dart';
import 'package:book_store/core/services/audio_player_service.dart';
import 'package:book_store/data/local/models/book_local_models.dart';
import 'package:book_store/features/chapter_reader/controllers/chapter_reader_controller.dart';
import 'package:book_store/features/chapter_reader/widgets/image_reader.dart';
import 'package:book_store/features/chapter_reader/widgets/reader_audio_player.dart';
import 'package:book_store/features/chapter_reader/widgets/text_reader.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChapterReaderScreen extends StatefulWidget {
  const ChapterReaderScreen({super.key});

  @override
  State<ChapterReaderScreen> createState() => _ChapterReaderScreenState();
}

class _ChapterReaderScreenState extends State<ChapterReaderScreen> {
  late final ChapterReaderController controller;
  final AudioPlayerService audio = Get.find<AudioPlayerService>();

  @override
  void initState() {
    super.initState();
    controller = Get.find<ChapterReaderController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      audio.isReaderActive.value = true;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      audio.isReaderActive.value = false;
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      controller.chapterKey.value;

      final reader = controller.bookType.value == LocalBookType.text
          ? TextReader(key: controller.chapterKey.value)
          : ImageReader(key: controller.chapterKey.value);

      return PopScope(
        canPop: true,
        onPopInvoked: (didPop) {
          if (didPop) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              audio.isReaderActive.value = false;
            });
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(controller.chapterTitle.value),
            actions: [
              Obx(() {
                final isFavorite = controller.isPageFavorite.value;
                return IconButton(
                  icon: Icon(
                    isFavorite ? Icons.bookmark : Icons.bookmark_border,
                    color: isFavorite ? context.sacred.gold : null,
                  ),
                  onPressed: controller.togglePageFavorite,
                );
              }),
            ],
          ),
          body: Column(
            children: [
              Expanded(child: reader),
              const ReaderAudioPlayer(),
            ],
          ),
        ),
      );
    });
  }
}
