import 'package:book_store/data/local/models/book_local_models.dart';
import 'package:book_store/data/repositories/settings_repository.dart';
import 'package:book_store/features/chapter_reader/controllers/text_reader_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TextReader extends GetView<TextReaderController> {
  const TextReader({super.key});

  @override
  Widget build(BuildContext context) {
    final segments = controller.chapterReader.chapter.contentSegments;
    final contentText = controller.chapterReader.chapter.contentText;
    final settings = Get.find<SettingsRepository>();

    return Obx(() {
      final hasAudio = controller.hasAudio.value;
      final scale = settings.fontSizeScale.value;
      final baseStyle = Theme.of(context).textTheme.bodyLarge;
      final scaledStyle = baseStyle?.copyWith(
        fontSize: (baseStyle?.fontSize ?? 16.0) * scale,
      );

      // Use segments if available, otherwise fall back to line‑based rendering
      final items = _buildItems(
        context: context,
        segments: segments,
        contentText: contentText,
        baseStyle: scaledStyle,
        scale: scale,
        hasAudio: hasAudio,
        currentIndex: controller.currentSegmentIndex.value,
        segmentKeys: controller.segmentKeys,
      );

      final isSegmented = segments != null && segments.isNotEmpty;

      // Wrap with border and page indicator
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Scrollable text area
            Expanded(
              child: isSegmented
                  ? SingleChildScrollView(
                      controller: controller.scrollController,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: items,
                      ),
                    )
                  : ListView(
                      controller: controller.scrollController,
                      padding: const EdgeInsets.all(20),
                      children: items,
                    ),
            ),
            // Page indicator
            _buildPageIndicator(context),
          ],
        ),
      );
    });
  }

  List<Widget> _buildItems({
    required BuildContext context,
    required List<TextSegment>? segments,
    required String? contentText,
    required TextStyle? baseStyle,
    required double scale,
    required bool hasAudio,
    required int currentIndex,
    required List<GlobalKey> segmentKeys,
  }) {
    final theme = Theme.of(context);

    // 1) If we have segments, use them (with karaoke if active)
    if (segments != null && segments.isNotEmpty) {
      return segments.asMap().entries.map((entry) {
        final index = entry.key;
        final segment = entry.value;
        return _buildSegmentWidget(
          content: segment.content,
          index: index,
          isCurrent: hasAudio && index == currentIndex,
          baseStyle: baseStyle,
          scale: scale,
          theme: theme,
          key: index < segmentKeys.length ? segmentKeys[index] : null,
        );
      }).toList();
    }

    // 2) Fallback: split contentText into lines
    final lines = (contentText ?? '').split('\n');
    return lines.asMap().entries.map((entry) {
      final index = entry.key;
      final line = entry.value;
      // No karaoke for fallback
      final isCurrent = false;
      final key = index < segmentKeys.length ? segmentKeys[index] : null;
      return _buildSegmentWidget(
        content: line,
        index: index,
        isCurrent: isCurrent,
        baseStyle: baseStyle,
        scale: scale,
        theme: theme,
        key: key,
      );
    }).toList();
  }

  Widget _buildSegmentWidget({
    required String content,
    required int index,
    required bool isCurrent,
    required TextStyle? baseStyle,
    required double scale,
    required ThemeData theme,
    GlobalKey? key,
  }) {
    final trimmed = content.trimLeft();
    final isTitle = trimmed.startsWith('# ');
    final isSubtitle = trimmed.startsWith('## ');

    TextStyle style = baseStyle ?? const TextStyle();

    if (isTitle) {
      style = style.copyWith(
        fontSize: (baseStyle?.fontSize ?? 16.0) * scale * 1.6,
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onSurface,
      );
    } else if (isSubtitle) {
      style = style.copyWith(
        fontSize: (baseStyle?.fontSize ?? 16.0) * scale * 1.3,
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.9),
      );
    }

    if (isCurrent) {
      style = style.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.primary,
      );
    }

    String displayText = content;
    if (isTitle) displayText = content.substring(2).trim();
    if (isSubtitle) displayText = content.substring(3).trim();

    double verticalPad = 8.0;
    if (isTitle)
      verticalPad = 16.0;
    else if (isSubtitle)
      verticalPad = 12.0;

    return Container(
      key: key,
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: verticalPad),
      child: Text(displayText, style: style),
    );
  }

  Widget _buildPageIndicator(BuildContext context) {
    // Rebuild whenever the ScrollController notifies (scroll position changes).
    return AnimatedBuilder(
      animation: controller.scrollController,
      builder: (context, child) {
        if (!controller.scrollController.hasClients) {
          return const SizedBox.shrink();
        }

        final position = controller.scrollController.position;
        final viewportHeight = position.viewportDimension;
        final maxScroll = position.maxScrollExtent;
        final offset = position.pixels;

        if (maxScroll <= 0 || viewportHeight <= 0) {
          return const SizedBox.shrink();
        }

        // total content height = maxScroll + viewportHeight (approx)
        final totalHeight = maxScroll + viewportHeight;
        final totalPages = (totalHeight / viewportHeight).ceil();
        final currentPage = (offset / viewportHeight).floor() + 1;
        final displayPage = currentPage.clamp(1, totalPages);
        final progress = maxScroll > 0
            ? (offset / maxScroll * 100).clamp(0, 100).toInt()
            : 0;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$progress%',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              Text(
                'Page $displayPage of $totalPages',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
