import 'package:book_store/data/local/models/book_local_models.dart';
import 'package:book_store/features/chapter_reader/controllers/text_reader_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TextReader extends GetView<TextReaderController> {
  const TextReader({super.key});

  @override
  Widget build(BuildContext context) {
    final segments = controller.chapterReader.chapter.contentSegments;
    final contentText = controller.chapterReader.chapter.contentText;

    return Obx(() {
      final hasKaraoke = controller.hasAudio.value && segments?.isNotEmpty == true;

      if (hasKaraoke) {
        return SingleChildScrollView(
          controller: controller.scrollController,
          padding: const EdgeInsets.all(16.0),
          child: _buildKaraoke(context, segments!),
        );
      }

      return SingleChildScrollView(
        controller: controller.scrollController,
        padding: const EdgeInsets.all(16.0),
        child: Text(
          contentText ?? 'No content available.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    });
  }

  Widget _buildKaraoke(BuildContext context, List<TextSegment> segments) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: segments.asMap().entries.map((entry) {
        final index = entry.key;
        final segment = entry.value;
        final isCurrent = index == controller.currentSegmentIndex.value;
        return Container(
          key: controller.segmentKeys[index],
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            segment.content,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
              color: isCurrent
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        );
      }).toList(),
    );
  }
}
