import 'package:book_store/common/utils/snackbar_helper.dart';
import 'package:book_store/data/local/models/book_local_models.dart';
import 'package:book_store/data/remote/sync_manager.dart';
import 'package:book_store/data/repositories/book_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DownloadsController extends GetxController {
  final BookRepository _repository = Get.find<BookRepository>();
  final SyncManager _syncManager = Get.find<SyncManager>();

  final books = <LocalBook>[].obs;
  final chapterCounts = <String, int>{}.obs;
  final queue = <Map<String, Object?>>[].obs;
  final isLoading = true.obs;
  final errorMessage = Rxn<String>();

  @override
  Future<void> onInit() async {
    super.onInit();
    await loadData();
  }

  Future<void> loadData() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      final loadedBooks = await _repository.getBooks();
      final counts = <String, int>{};
      for (final book in loadedBooks) {
        final chapters = await _repository.getChapters(book.id);
        counts[book.id] = chapters.length;
      }
      final loadedQueue = await _repository.getDownloadQueue();

      books.value = loadedBooks;
      chapterCounts.assignAll(counts);
      queue.value = loadedQueue;
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'Failed to load downloads: $e';
      debugPrint('DownloadsController.loadData error: $e');
    }
  }

  Future<void> retryChapter(String chapterId) async {
    try {
      await _syncManager.downloadChapter(chapterId);
      await loadData();
    } catch (e) {
      SnackbarHelper.show('Retry failed: $e');
    }
  }

  Future<void> deleteBook(LocalBook book) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete downloaded book?'),
        content: Text('This will remove "${book.title}" and its media.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _repository.deleteBook(book.id);
      await loadData();
    }
  }

  int get queueSectionCount => queue.isNotEmpty ? queue.length + 1 : 0;
  int get booksSectionCount => books.isNotEmpty ? books.length + 1 : 0;

  Widget queueIcon(String status) {
    return switch (status) {
      'COMPLETED' => const Icon(Icons.download_done, color: Colors.green),
      'FAILED' => const Icon(Icons.error, color: Colors.red),
      'DOWNLOADING' => const Icon(Icons.downloading),
      'PENDING' => const Icon(Icons.pending),
      _ => const Icon(Icons.download),
    };
  }
}
