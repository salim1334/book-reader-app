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
      appBar: AppBar(title: const Text('የወረዱ መጽሐፍት')),
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
            'የማውረድ ተራ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      }
      if (index <= queue.length) {
        final item = queue[index - 1];
        final chapterId = item['chapter_id'] as String? ?? '';
        final bookId = item['book_id'] as String? ?? '';
        final status = item['status'] as String? ?? 'ያልታወቀ';
        final queueProgress = (item['progress'] as num?)?.toDouble() ?? 0.0;
        final retryCount = (item['retry_count'] as num?)?.toInt() ?? 0;
        final canRetry = status == 'FAILED';
        final isDownloading = status == 'DOWNLOADING';
        final chapterTitle = controller.queueChapterTitles[chapterId] ??
            (chapterId.length > 8
                ? 'ምዕራፍ ${chapterId.substring(0, 8)}...'
                : 'ምዕራፍ $chapterId');
        final bookTitle = controller.queueBookTitles[bookId] ??
            (bookId.length > 8
                ? 'መጽሐፍ ${bookId.substring(0, 8)}...'
                : 'መጽሐፍ $bookId');
        final progressText =
            '${(queueProgress * 100).toStringAsFixed(0)}%';
        final statusLabel = controller.queueStatusLabel(status);
        return ListTile(
          leading: isDownloading
              ? Obx(() {
                  final live = Get.find<SyncManager>()
                      .chapterDownloadProgress[chapterId];
                  final progress = live ?? queueProgress;
                  return SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      value: progress > 0 ? progress : null,
                      strokeWidth: 2,
                    ),
                  );
                })
              : controller.queueIcon(status),
          title: Text(bookTitle),
          subtitle: isDownloading
              ? Obx(() {
                  final live = Get.find<SyncManager>()
                      .chapterDownloadProgress[chapterId];
                  final progress = live ?? queueProgress;
                  return Text(
                    '$chapterTitle • $statusLabel • ${(progress * 100).toStringAsFixed(0)}% • ድጋሚ ሙከራዎች: $retryCount',
                  );
                })
              : Text(
                  '$chapterTitle • $statusLabel • $progressText • ድጋሚ ሙከራዎች: $retryCount',
                ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (canRetry)
                IconButton(
                  icon: const Icon(Icons.replay),
                  tooltip: 'ድጋሜ ይሞክሩ',
                  onPressed: () => controller.retryChapter(chapterId),
                ),
              IconButton(
                icon: const Icon(Icons.delete),
                tooltip: status == 'DOWNLOADING' ? 'አቋርጥ' : 'አስወግድ',
                onPressed: () => controller.cancelQueueItem(chapterId),
              ),
            ],
          ),
        );
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
    return ListTile(
      leading: const Icon(Icons.book),
      title: Text(book.title),
      subtitle: Obx(() {
        final total = controller.chapterCounts[book.id] ?? 0;
        final downloaded = controller.downloadedCounts[book.id] ?? 0;
        final live =
            Get.find<SyncManager>().bookDownloadProgress[book.id];
        final storedProgress = total > 0 ? downloaded / total : 0.0;
        final progress = live != null
            ? (live > 0 ? live : null)
            : storedProgress;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${book.type.name} • $downloaded / $total ምዕራፍ ተወርዋል',
            ),
            const SizedBox(height: 4),
            LinearProgressIndicator(value: progress),
          ],
        );
      }),
      trailing: controller.isBundledBook(book.id)
          ? null
          : IconButton(
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
      final progress = _activeProgress(syncManager);
      final hasProgress = progress != null && progress > 0;

      return AnimatedSize(
        duration: const Duration(milliseconds: 250),
        child: isActive
            ? Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hasProgress)
                      LinearProgressIndicator(value: progress)
                    else
                      const Row(
                        children: [
                          SizedBox(
                            width: 32,
                            height: 32,
                            child: CircularProgressIndicator(strokeWidth: 3),
                          ),
                          SizedBox(width: 12),
                          Text('በማውረድ ላይ...'),
                        ],
                      ),
                    const SizedBox(height: 8),
                    Text(
                      hasProgress
                          ? '${state.name}... ${(progress * 100).toStringAsFixed(0)}%'
                          : '${state.name}...',
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

  double? _activeProgress(SyncManager syncManager) {
    double total = 0.0;
    int count = 0;
    for (final value in syncManager.bookDownloadProgress.values) {
      if (value > 0 && value < 1) {
        total += value;
        count++;
      }
    }
    for (final value in syncManager.chapterDownloadProgress.values) {
      if (value > 0 && value < 1) {
        total += value;
        count++;
      }
    }
    if (count == 0) return null;
    return total / count;
  }
}
