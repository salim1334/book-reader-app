import 'package:book_store/common/widgets/chapter_list_tile.dart';
import 'package:book_store/common/widgets/cover_image.dart';
import 'package:book_store/common/widgets/error_view.dart';
import 'package:book_store/common/widgets/loading_indicator.dart';
import 'package:book_store/core/theme/sacred_theme_extension.dart';
import 'package:book_store/core/utils/extensions/theme_extension.dart';
import 'package:book_store/data/local/models/book_local_models.dart';
import 'package:book_store/features/book_details/controllers/book_details_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BookDetailsScreen extends GetView<BookDetailsController> {
  const BookDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(controller.book.value?.title ?? '')),
        actions: [
          Obx(() {
            final isFavorite = controller.isBookFavorite.value;
            return IconButton(
              icon: Icon(
                isFavorite ? Icons.bookmark : Icons.bookmark_border,
                color: isFavorite ? context.sacred.gold : null,
              ),
              onPressed: controller.toggleBookFavorite,
              tooltip: 'Favorite',
            );
          }),
        ],
      ),
      body: Obx(() {
        final isLoading = controller.isLoading.value;
        final book = controller.book.value;
        final error = controller.errorMessage.value;

        // ---- Handle initial screen states ----
        if (isLoading && book == null) {
          return const LoadingIndicator();
        }

        if (error != null && book == null) {
          return ErrorView(message: error, onRetry: controller.refresh);
        }

        if (book == null) {
          return const LoadingIndicator();
        }

        // ---- Main Content ----
        return RefreshIndicator(
          onRefresh: controller.refresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Header Card
              SliverToBoxAdapter(child: _HeaderCard(book: book)),

              // Progress Bar
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: _ProgressBar(),
                ),
              ),

              // Update Banner
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: _UpdateBanner(),
                ),
              ),

              // Section Title
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(),
                      const SizedBox(height: 12),
                      Text(
                        'Chapters',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Chapters List
              Obx(() {
                final chapters = controller.chapters;
                if (chapters.isEmpty) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: Text('No chapters available')),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.only(bottom: 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final chapter = chapters[index];
                      return Obx(() {
                        final isOutdated = controller.outdatedChapterIds
                            .contains(chapter.id);
                        final progress =
                            controller.chapterProgress[chapter.id] ?? 0.0;
                        final isDownloading =
                            controller.downloadingChapterId.value == chapter.id;
                        final isFavorite =
                            controller.chapterFavoriteStates[chapter.id] ??
                            false;

                        return ChapterListTile(
                          index: index,
                          chapter: chapter,
                          progress: progress,
                          isOutdated: isOutdated,
                          isDownloading: isDownloading,
                          isFavorite: isFavorite,
                          onFavorite: () =>
                              controller.toggleChapterFavorite(chapter.id),
                          onTap: () {
                            if (chapter.isDownloaded && !isOutdated) {
                              controller.openChapter(chapter);
                            } else {
                              controller.downloadChapter(chapter);
                            }
                          },
                        );
                      });
                    }, childCount: chapters.length),
                  ),
                );
              }),
            ],
          ),
        );
      }),
    );
  }
}

// ---- Extracted Private Sub-Widgets ----

class _HeaderCard extends StatelessWidget {
  final LocalBook book;

  const _HeaderCard({required this.book});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Chip(
                      label: Text(
                        book.type == LocalBookType.text ? 'TEXT' : 'IMAGE',
                        style: const TextStyle(fontSize: 12),
                      ),
                      visualDensity: VisualDensity.compact,
                      backgroundColor: theme.colorScheme.primaryContainer
                          .withOpacity(0.5),
                      side: BorderSide.none,
                    ),
                    if (book.description != null &&
                        book.description!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        book.description!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Hero(
                tag: 'book_cover_${book.id}',
                child: Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: book.coverUrl != null && book.coverUrl!.isNotEmpty
                        ? CoverImage(
                            coverUrl: book.coverUrl!,
                            width: 120,
                            height: 180,
                            borderRadius: 16,
                          )
                        : Container(
                            width: 120,
                            height: 180,
                            color: theme.colorScheme.primaryContainer,
                            child: Icon(
                              Icons.menu_book,
                              size: 60,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressBar extends GetView<BookDetailsController> {
  const _ProgressBar();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(() {
      final progress = controller.bookProgressPercent.value;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Reading progress',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              color: theme.colorScheme.primary,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
            ),
          ),
        ],
      );
    });
  }
}

class _UpdateBanner extends GetView<BookDetailsController> {
  const _UpdateBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Obx(() {
      if (!controller.hasUpdate.value) return const SizedBox.shrink();

      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: colors.secondaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.update, color: colors.onSecondaryContainer, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'New version available',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colors.onSecondaryContainer,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap update to download the latest changes.',
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.onSecondaryContainer.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              controller.isLoading.value
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colors.onSecondaryContainer,
                      ),
                    )
                  : TextButton(
                      onPressed: controller.updateBook,
                      style: TextButton.styleFrom(
                        backgroundColor: colors.secondary,
                        foregroundColor: colors.onSecondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text('UPDATE'),
                    ),
            ],
          ),
        ),
      );
    });
  }
}
