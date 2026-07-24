import 'package:book_store/common/widgets/empty_view.dart';
import 'package:book_store/common/widgets/error_view.dart';
import 'package:book_store/common/widgets/loading_indicator.dart';
import 'package:book_store/data/remote/sync_manager.dart';
import 'package:book_store/features/downloads/controllers/downloads_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DownloadsScreen extends GetView<DownloadsController> {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ማውረዶች')),
      body: Column(
        children: [
          _SyncProgressHeader(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const LoadingIndicator();
              }

              final error = controller.errorMessage.value;
              if (error != null) {
                return ErrorView(message: error, onRetry: controller.loadData);
              }

              if (controller.queue.isEmpty && controller.books.isEmpty) {
                return const EmptyView(message: 'እስካሁን ምንም አልወረደም።');
              }

              return RefreshIndicator(
                onRefresh: controller.loadData,
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount:
                      controller.queueSectionCount +
                      controller.booksSectionCount,
                  itemBuilder: (context, index) {
                    return _buildItem(context, index);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index) {
    final queue = controller.queue;
    final books = controller.books;

    if (queue.isNotEmpty) {
      if (index == 0) {
        return const ListTile(
          title: Text(
            'ለማውረድ የተሰለፉ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      }
      if (index <= queue.length) {
        final item = queue[index - 1];
        final chapterId = item['chapter_id'] as String? ?? '';
        final status = item['status'] as String? ?? 'ያልታወቀ';
        final queueProgress = (item['progress'] as num?)?.toDouble() ?? 0.0;
        final retryCount = (item['retry_count'] as num?)?.toInt() ?? 0;
        final canRetry = status == 'FAILED';
        final isDownloading = status == 'DOWNLOADING';
        return Obx(() {
          final liveProgress = isDownloading
              ? Get.find<SyncManager>().chapterDownloadProgress[chapterId]
              : null;
          final progress = liveProgress ?? queueProgress;
          return ListTile(
            leading: isDownloading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 2,
                    ),
                  )
                : controller.queueIcon(status),
            title: Text(
              'ምዕራፍ ${chapterId.length > 8 ? chapterId.substring(0, 8) : chapterId}...',
            ),
            subtitle: Text(
              '$status • ${(progress * 100).toStringAsFixed(0)}% • ድጋሚ ሙከራዎች: $retryCount',
            ),
            trailing: canRetry
                ? IconButton(
                    icon: const Icon(Icons.replay),
                    onPressed: () => controller.retryChapter(chapterId),
                  )
                : null,
          );
        });
      }
    }

    final bookOffset = controller.queueSectionCount;
    if (index == bookOffset) {
      return const ListTile(
        title: Text(
          'የወረዱ መጻሕፍት',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      );
    }

    final bookIndex = index - bookOffset - 1;
    final book = books[bookIndex];
    final chapterCount = controller.chapterCounts[book.id] ?? 0;
    return ListTile(
      leading: const Icon(Icons.book),
      title: Text(book.title),
      subtitle: Text(
        '${book.type.name} • $chapterCount ምዕራፍ${chapterCount == 1 ? '' : 'ች'}',
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () => controller.deleteBook(book),
      ),
    );
  }
}

class _SyncProgressHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final syncManager = Get.find<SyncManager>();

    return Obx(() {
      final state = syncManager.syncState.value;
      final isActive =
          state == SyncState.syncing || state == SyncState.downloading;

      return AnimatedSize(
        duration: const Duration(milliseconds: 250),
        child: isActive
            ? Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const LinearProgressIndicator(),
                    const SizedBox(height: 8),
                    Text(
                      '${state.name}...',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (syncManager.currentDownload != null)
                      Obx(
                        () => Text(
                          syncManager.currentDownload!.value,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                  ],
                ),
              )
            : const SizedBox.shrink(),
      );
    });
  }
}
