import 'package:book_store/data/local/models/book_local_models.dart';
import 'package:book_store/features/chapter_reader/controllers/chapter_reader_controller.dart';
import 'package:book_store/features/chapter_reader/widgets/image_reader.dart';
import 'package:book_store/features/chapter_reader/widgets/reader_audio_player.dart';
import 'package:book_store/features/chapter_reader/widgets/text_reader.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChapterReaderScreen extends GetView<ChapterReaderController> {
  const ChapterReaderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reader = controller.book.type == LocalBookType.text
        ? const TextReader()
        : const ImageReader();

    return Scaffold(
      appBar: AppBar(title: Text(controller.chapter.title)),
      body: Column(
        children: [
          const ReaderAudioPlayer(),
          Expanded(child: reader),
        ],
      ),
    );
  }
}
