import 'package:book_store/common/utils/snackbar_helper.dart';
import 'package:book_store/data/local/models/book_local_models.dart';
import 'package:book_store/data/remote/sync_manager.dart';
import 'package:book_store/data/repositories/book_repository.dart';
import 'package:book_store/data/repositories/settings_repository.dart';
import 'package:book_store/features/book_details/presentation/arguments/book_details_args.dart';
import 'package:book_store/features/chapter_reader/presentation/arguments/chapter_reader_args.dart';
import 'package:book_store/features/home/domain/entities/continue_reading.dart';
import 'package:book_store/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final BookRepository _bookRepository = Get.find<BookRepository>();
  final SyncManager _syncManager = Get.find<SyncManager>();
  final SettingsRepository _settings = Get.find<SettingsRepository>();

  final books = <LocalBook>[].obs;
  final continueReading = Rxn<ContinueReading>();
  final isLoading = true.obs;
  final errorMessage = Rxn<String>();
  final isOffline = false.obs;
  RxBool get offlineMode => _settings.offlineMode;
  final downloadingBookId = Rxn<String>();
  final downloadedBooks = <String, bool>{}.obs;
  final bookProgress = <String, double>{}.obs;
  final bookFavorites = <String, bool>{}.obs;

  Worker? _offlineModeWorker;
  Worker? _autoDownloadWorker;

  @override
  Future<void> onInit() async {
    super.onInit();
    await initialize();
    _bindSettingWorkers();
  }

  void _bindSettingWorkers() {
    _offlineModeWorker = ever(_settings.offlineMode, (_) => loadBooks());
    _autoDownloadWorker = ever(_settings.autoDownload, (_) {
      if (_settings.autoDownload.value) autoSync();
    });
  }

  @override
  Future<void> onClose() async {
    _offlineModeWorker?.dispose();
    _autoDownloadWorker?.dispose();
    super.onClose();
  }

  Future<void> initialize() async {
    await loadBooks();
    await autoSync();
  }

  Future<void> loadBooks() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;
      final offlineOnly = _settings.offlineMode.value;

      final loadedBooks = await _bookRepository.getBooks();
      final cont = await _loadContinueReading();
      final downloaded = <String, bool>{};
      final progress = <String, double>{};
      final favorites = <String, bool>{};

      for (final book in loadedBooks) {
        downloaded[book.id] = await _isBookDownloaded(book);
        progress[book.id] = await _bookRepository.getBookProgressPercent(book.id);
        favorites[book.id] = await _bookRepository.isBookFavorite(book.id);
      }

      final booksToShow = offlineOnly
          ? loadedBooks.where((book) => downloaded[book.id] == true).toList()
          : loadedBooks;

      books.value = booksToShow;
      continueReading.value = cont;
      downloadedBooks.assignAll(downloaded);
      bookProgress.assignAll(progress);
      bookFavorites.assignAll(favorites);
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'Failed to load books: $e';
      debugPrint('HomeController.loadBooks error: $e');
    }
  }

  Future<bool> _isBookDownloaded(LocalBook book) async {
    final chapters = await _bookRepository.getChapters(book.id);
    return chapters.isNotEmpty && chapters.every((c) => c.isDownloaded);
  }

  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  Future<ContinueReading?> _loadContinueReading() async {
    final progress = await _bookRepository.getLastReadingProgress();
    if (progress == null) return null;

    final bookId = progress['book_id']?.toString();
    final chapterId = progress['chapter_id']?.toString();
    if (bookId == null || chapterId == null) return null;

    final book = await _bookRepository.getBook(bookId);
    final chapter = await _bookRepository.getChapter(chapterId);
    if (book == null || chapter == null || !chapter.isDownloaded) return null;

    return ContinueReading(
      book: book,
      chapter: chapter,
      pageIndex: _toInt(progress['last_page_index']),
      positionMs: _toInt(progress['last_position_ms']),
    );
  }

  Future<void> autoSync() async {
    final online = await _syncManager.isOnline();
    isOffline.value = !online || _settings.offlineMode.value;
    if (!online) return;

    try {
      await _syncManager.syncCatalog();
      await loadBooks();

      if (_settings.autoDownload.value) {
        final allBooks = await _bookRepository.getBooks();
        for (final book in allBooks) {
          if (!(downloadedBooks[book.id] ?? false)) {
            await downloadBook(book);
          }
        }
      }
    } catch (e) {
      SnackbarHelper.show('Could not refresh catalog: $e');
    }
  }

  Future<void> downloadBook(LocalBook book) async {
    downloadingBookId.value = book.id;
    try {
      await _syncManager.downloadBook(book.id);
      await loadBooks();
      SnackbarHelper.show('${book.title} downloaded');
    } catch (e) {
      SnackbarHelper.show('Download failed: $e');
    } finally {
      downloadingBookId.value = null;
    }
  }

  Future<void> toggleBookFavorite(LocalBook book) async {
    final newValue = !(bookFavorites[book.id] ?? false);
    await _bookRepository.setBookFavorite(book.id, newValue);
    bookFavorites[book.id] = newValue;
  }

  void openBook(LocalBook book) {
    Get.toNamed(
      Routes.bookDetails,
      arguments: BookDetailsArgs(book: book),
    );
  }

  void openContinueReading() {
    final cont = continueReading.value;
    if (cont == null) return;

    Get.toNamed(
      Routes.chapterReader,
      arguments: ChapterReaderArgs(
        book: cont.book,
        chapter: cont.chapter,
        initialPageIndex: cont.pageIndex,
        initialPositionMs: cont.positionMs,
      ),
    );
  }
}
