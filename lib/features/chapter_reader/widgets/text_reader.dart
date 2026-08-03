import 'package:book_store/core/constants/app_texts.dart';
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
      final orientation = MediaQuery.of(context).orientation;
      final isLandscape = orientation == Orientation.landscape;
      // final immersive = chapterController.isImmersiveMode.value;

      final hasAudio = controller.hasAudio.value;
      final scale = settings.fontSizeScale.value;

      final baseStyle = Theme.of(context).textTheme.bodyLarge;
      final scaledStyle = baseStyle?.copyWith(
        fontSize: (baseStyle.fontSize ?? 16.0) * scale,
      );

      // Build content items
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

      // Dynamic padding only
      // final contentPadding = immersive || isLandscape
      //     ? const EdgeInsets.symmetric(horizontal: 16, vertical: 12)
      //     : const EdgeInsets.all(20);

      // IMPORTANT: ONE scrollable instance only
      final Widget scrollable = isSegmented
          ? SingleChildScrollView(
              controller: controller.scrollController,
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: items,
              ),
            )
          : ListView(
              controller: controller.scrollController,
              padding: EdgeInsets.all(20),
              children: items,
            );

      // Constrain width in landscape for readability
      final Widget readerContent = Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isLandscape ? 720 : double.infinity,
          ),
          child: scrollable,
        ),
      );

      // SINGLE widget tree for all modes
      return AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        margin: isLandscape
            ? EdgeInsets.zero
            : const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: isLandscape
            ? null
            : BoxDecoration(
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.3),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.shadow.withValues(alpha: 0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
        child: Column(
          children: [
            Expanded(child: readerContent),

            // Hide only the indicator, not the scrollable
            _buildPageIndicator(context, items.length),
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

    // Build a list of page contents. Each audio segment is a page; otherwise
    // split the full contentText on double newlines to recover pages.
    final List<String> pages;
    if (segments != null && segments.isNotEmpty) {
      pages = segments.map((s) => s.content).toList();
    } else {
      final normalized = (contentText ?? '').replaceAll('\r\n', '\n');
      final splitPages = normalized
          .split('\n\n')
          .where((p) => p.trim().isNotEmpty)
          .toList();
      pages = splitPages.isEmpty ? [normalized] : splitPages;
    }

    final items = <Widget>[];
    for (var i = 0; i < pages.length; i++) {
      final isCurrent = hasAudio && i == currentIndex;
      items.add(
        _buildPageBlock(
          content: pages[i],
          isCurrent: isCurrent,
          isLast: i == pages.length - 1,
          baseStyle: baseStyle,
          scale: scale,
          theme: theme,
          key: i < segmentKeys.length ? segmentKeys[i] : null,
        ),
      );
    }
    return items;
  }

  Widget _buildPageBlock({
    required String content,
    required bool isCurrent,
    required bool isLast,
    required TextStyle? baseStyle,
    required double scale,
    required ThemeData theme,
    GlobalKey? key,
  }) {
    final normalized = content.replaceAll('\r\n', '\n');
    final lines = normalized
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .toList();

    final children = lines
        .map(
          (line) => _buildLine(
            content: line,
            isCurrent: isCurrent,
            baseStyle: baseStyle,
            scale: scale,
            theme: theme,
          ),
        )
        .toList();

    if (!isLast) {
      children.add(const Divider(height: 24, thickness: 1));
    }

    return Container(
      key: key,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildLine({
    required String content,
    required bool isCurrent,
    required TextStyle? baseStyle,
    required double scale,
    required ThemeData theme,
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
    if (isTitle) {
      displayText = trimmed.substring(2).trim();
    } else if (isSubtitle) {
      displayText = trimmed.substring(3).trim();
    }

    double verticalPad = 8.0;
    if (isTitle) {
      verticalPad = 16.0;
    } else if (isSubtitle) {
      verticalPad = 12.0;
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: verticalPad),
      child: Text(displayText, style: style),
    );
  }

  Widget _buildPageIndicator(BuildContext context, int pageCount) {
    // Rebuild whenever the ScrollController notifies (scroll position changes).
    return AnimatedBuilder(
      animation: controller.scrollController,
      builder: (context, child) {
        final scroll = controller.scrollController;

        if (!scroll.hasClients || !scroll.position.hasViewportDimension) {
          return const SizedBox.shrink();
        }

        final position = controller.scrollController.position;
        final viewportHeight = position.viewportDimension;
        final maxScroll = position.maxScrollExtent;
        final offset = position.pixels;

        if (maxScroll <= 0 || viewportHeight <= 0) {
          return const SizedBox.shrink();
        }

        final totalPages = pageCount;
        final raw = (offset / maxScroll) * totalPages;
        final currentPage = raw.floor() + 1;
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
                AppTexts.textReaderProgressPercent(progress),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              Text(
                AppTexts.textReaderPageIndicator(displayPage, totalPages),
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
