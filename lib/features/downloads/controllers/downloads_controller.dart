import 'package:book_store/common/utils/snackbar_helper.dart';
import 'package:book_store/core/exceptions/storage_exceptions.dart';
import 'package:book_store/data/local/models/book_local_models.dart';
import 'package:book_store/data/local/services/bundled_content_seeder.dart';
import 'package:book_store/data/remote/sync_manager.dart';
import 'package:book_store/data/repositories/book_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DownloadsController extends GetxController {
  final BookRepository _repository = Get.find<BookRepository>();
  final SyncManager _syncManager = Get.find<SyncManager>();

  final books = <LocalBook>[].obs;
  final chapterCounts = <String, int>{}.obs;
  final downloadedCounts = <String, int>{}.obs;
  final queue = <Map<String, Object?>>[].obs;
  final queueChapterTitles = <String, String>{}.obs;
  final queueBookTitles = <String, String>{}.obs;
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
      final dls = <String, int>{};
      await Future.wait(
        loadedBooks.map((book) async {
          final chapters = await _repository.getChapters(book.id);
          counts[book.id] = chapters.length;
          dls[book.id] = chapters.where((c) => c.isDownloaded).length;
        }),
      );
      final loadedQueue = (await _repository.getDownloadQueue())
          .where((item) => (item['status'] as String?) != 'COMPLETED')
          .toList();

      final chapterTitles = <String, String>{};
      final bookTitles = <String, String>{};
      await Future.wait(
        loadedQueue.map((item) async {
          final chapterId = item['chapter_id'] as String? ?? '';
          final bookId = item['book_id'] as String? ?? '';

          final chapter = await _repository.getChapter(chapterId);
          if (chapter != null) chapterTitles[chapterId] = chapter.title;

          final book = await _repository.getBook(bookId);
          if (book != null) bookTitles[bookId] = book.title;
        }),
      );

      books.value = loadedBooks;
      chapterCounts.assignAll(counts);
      downloadedCounts.assignAll(dls);
      queue.value = loadedQueue;
      queueChapterTitles.assignAll(chapterTitles);
      queueBookTitles.assignAll(bookTitles);
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'ማውረድ አልተቻለም ድጋሜ ይሞክሩ';
      debugPrint('DownloadsController.loadData error:  ');
    }
  }

  Future<void> retryChapter(String chapterId) async {
    try {
      await _syncManager.downloadChapter(chapterId);
    } on StorageFullException catch (e) {
      SnackbarHelper.show(e.toString());
    } catch (e) {
      SnackbarHelper.show('ምዕራፍ ማውረድ አልተቻለም ድጋሜ ይሞክሩ');
    } finally {
      await loadData();
    }
  }

  Future<void> cancelQueueItem(String chapterId) async {
    try {
      _syncManager.cancelDownload(chapterId);
      await _repository.deleteQueueItem(chapterId);
    } finally {
      await loadData();
    }
  }

  Future<void> deleteBook(LocalBook book) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('የወረደውን መጽሐፍ ይጥፉ?'),
        content: Text('"${book.title}" እና የሚመለከተው ፋይሎች ይጠፋሉ።'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('ይቅር'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('አጥፋ'),
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

  bool isBundledBook(String bookId) =>
      BundledContentSeeder.bundledBookIds.contains(bookId);

  String queueStatusLabel(String status) {
    return switch (status) {
      'COMPLETED' => 'አልቋል',
      'FAILED' => 'አልተሳካም',
      'DOWNLOADING' => 'በማውረድ ላይ',
      'PENDING' => 'በተራ ላይ',
      _ => status,
    };
  }

  Widget queueIcon(String status) {
    final colors = Get.theme.colorScheme;
    return switch (status) {
      'COMPLETED' => Icon(Icons.download_done, color: colors.primary),
      'FAILED' => Icon(Icons.error, color: colors.error),
      'DOWNLOADING' => const Icon(Icons.downloading),
      'PENDING' => const Icon(Icons.pending),
      _ => const Icon(Icons.download),
    };
  }
}
