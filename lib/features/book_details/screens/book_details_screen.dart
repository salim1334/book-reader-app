import 'package:book_store/common/widgets/chapter_list_tile.dart';
import 'package:book_store/common/widgets/cover_image.dart';
import 'package:book_store/common/widgets/error_view.dart';
import 'package:book_store/common/widgets/loading_indicator.dart';
import 'package:book_store/data/local/models/book_local_models.dart';
import 'package:book_store/features/book_details/controllers/book_details_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BookDetailsScreen extends GetView<BookDetailsController> {
  const BookDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Obx(() => Text(controller.book.value?.title ?? ''))),
      body: Obx(() {
        if (controller.isLoading.value && controller.book.value == null) {
          return const LoadingIndicator();
        }

        final error = controller.errorMessage.value;
        if (error != null && controller.book.value == null) {
          return ErrorView(message: error, onRetry: controller.refresh);
        }

        final book = controller.book.value;
        if (book == null) {
          return const LoadingIndicator();
        }

        return RefreshIndicator(
          onRefresh: controller.refresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _UpdateBanner()),
              SliverToBoxAdapter(child: _buildCover(book.coverUrl)),
              SliverToBoxAdapter(child: _buildBookInfo(book)),
              if (controller.chapters.isEmpty)
                const SliverFillRemaining(
                  child: Center(child: Text('No chapters available')),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final chapter = controller.chapters[index];
                      return Obx(() {
                        final isOutdated = controller.outdatedChapterIds.contains(chapter.id);
                        final progress = controller.chapterProgress[chapter.id] ?? 0.0;
                        return ChapterListTile(
                          index: index,
                          chapter: chapter,
                          progress: progress,
                          isOutdated: isOutdated,
                          isDownloading: controller.downloadingChapterId.value == chapter.id,
                          onTap: () {
                            if (chapter.isDownloaded && !isOutdated) {
                              controller.openChapter(chapter);
                            } else {
                              controller.downloadChapter(chapter);
                            }
                          },
                        );
                      });
                    },
                    childCount: controller.chapters.length,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCover(String? coverUrl) {
    if (coverUrl == null || coverUrl.isEmpty) return const SizedBox.shrink();
    return CoverImage(
      coverUrl: coverUrl,
      borderRadius: 0,
      aspectRatio: 16 / 9,
    );
  }

  Widget _buildBookInfo(LocalBook book) {
    return Builder(
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              book.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Chip(
              label: Text(book.type == LocalBookType.text ? 'TEXT' : 'IMAGE'),
              visualDensity: VisualDensity.compact,
            ),
            if (book.description != null && book.description!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                book.description!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 16),
            Obx(
              () => Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: controller.bookProgressPercent.value,
                      color: Colors.green,
                      backgroundColor: Colors.grey.shade300,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('${(controller.bookProgressPercent.value * 100).round()}%'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UpdateBanner extends GetView<BookDetailsController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.hasUpdate.value) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.all(12.0),
        child: Card(
          color: Colors.orange.shade50,
          child: ListTile(
            leading: const Icon(Icons.update, color: Colors.orange),
            title: const Text('New version available'),
            subtitle: const Text('Some content has been updated. Tap update to download the latest changes.'),
            trailing: controller.isLoading.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : TextButton(
                    onPressed: controller.updateBook,
                    child: const Text('UPDATE'),
                  ),
          ),
        ),
      );
    });
  }
}
