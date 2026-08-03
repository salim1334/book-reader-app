import 'package:book_store/common/widgets/empty_view.dart';
import 'package:book_store/common/widgets/error_view.dart';
import 'package:book_store/common/widgets/loading_indicator.dart';
import 'package:book_store/data/remote/sync_manager.dart';
import 'package:book_store/features/downloads/controllers/downloads_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:book_store/core/constants/app_texts.dart';

class DownloadsScreen extends GetView<DownloadsController> {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppTexts.downloadsAppBarTitle)),
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
                return const EmptyView(message: AppTexts.downloadsEmptyMessage);
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
            AppTexts.downloadsQueueHeader,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      }
      if (index <= queue.length) {
        final item = queue[index - 1];
        final chapterId = item['chapter_id'] as String? ?? '';
        final bookId = item['book_id'] as String? ?? '';
        final status = item['status'] as String? ?? AppTexts.downloadsUnknownStatus;
        final queueProgress = (item['progress'] as num?)?.toDouble() ?? 0.0;
        final retryCount = (item['retry_count'] as num?)?.toInt() ?? 0;
        final canRetry = status == 'FAILED';
        final isDownloading = status == 'DOWNLOADING';
        final chapterTitle = controller.queueChapterTitles[chapterId] ??
            AppTexts.downloadsChapterTitle(chapterId, chapterId.length > 8);
        final bookTitle = controller.queueBookTitles[bookId] ??
            AppTexts.downloadsBookTitle(bookId, bookId.length > 8);
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
                    AppTexts.downloadsQueueItemSubtitle(chapterTitle, statusLabel, progress, retryCount),
                  );
                })
              : Text(
                  AppTexts.downloadsQueueItemSubtitle(chapterTitle, statusLabel, queueProgress, retryCount),
                ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (canRetry)
                IconButton(
                  icon: const Icon(Icons.replay),
                  tooltip: AppTexts.downloadsRetryTooltip,
                  onPressed: () => controller.retryChapter(chapterId),
                ),
              IconButton(
                icon: const Icon(Icons.delete),
                tooltip: status == 'DOWNLOADING' ? AppTexts.downloadsCancelTooltip : AppTexts.downloadsRemoveTooltip,
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
          AppTexts.downloadsAppBarTitle,
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
              AppTexts.downloadsBookProgress(book.type.name, downloaded, total),
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
                          Text(AppTexts.downloadsSyncing),
                        ],
                      ),
                    const SizedBox(height: 8),
                    Text(
                      hasProgress
                          ? AppTexts.downloadsSyncStateWithProgress(state.name, progress)
                          : AppTexts.downloadsSyncState(state.name),
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
