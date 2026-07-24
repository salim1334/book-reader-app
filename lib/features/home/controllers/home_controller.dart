import 'dart:async';

import 'package:book_store/common/utils/snackbar_helper.dart';
import 'package:book_store/core/services/reading_progress_service.dart';
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
  final ReadingProgressService _progressService = Get.find<ReadingProgressService>();

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
  Worker? _catalogSyncWorker;
  StreamSubscription<ReadingProgressUpdate>? _progressSubscription;
  @override
  Future<void> onInit() async {
    super.onInit();
    await initialize();
    _bindSettingWorkers();
    _bindReactiveListeners();

    // Instead of calling onInit(), just refresh favorites
    ever(_bookRepository.favoriteVersion, (_) => _refreshFavorites());
  }

  Future<void> _refreshFavorites() async {
    try {
      final favorites = <String, bool>{};
      for (final book in books) {
        favorites[book.id] = await _bookRepository.isBookFavorite(book.id);
      }
      bookFavorites.assignAll(favorites);
    } catch (e) {
      debugPrint('HomeController._refreshFavorites error: $e');
    }
  }


  void _bindSettingWorkers() {
    _offlineModeWorker = ever(_settings.offlineMode, (_) => loadBooks());
    _autoDownloadWorker = ever(_settings.autoDownload, (_) {
      if (_settings.autoDownload.value) autoSync();
    });
  }

  void _bindReactiveListeners() {
    _catalogSyncWorker = ever(
      _syncManager.lastCatalogSyncAt,
      (_) => loadBooks(silent: true),
    );
    _progressSubscription = _progressService.progressUpdates.listen(
      _onProgressUpdate,
      onError: (e) => debugPrint('HomeController progress stream error: $e'),
    );
  }

  @override
  Future<void> onClose() async {
    _offlineModeWorker?.dispose();
    _autoDownloadWorker?.dispose();
    _catalogSyncWorker?.dispose();
    await _progressSubscription?.cancel();
    super.onClose();
  }

  Future<void> initialize() async {
    await loadBooks();
    // Catalog sync is handled by SyncManager (startup, periodic, app resume).
    // The home screen simply reacts via lastCatalogSyncAt.
  }

  Future<void> loadBooks({bool silent = false}) async {
    try {
      if (!silent) {
        isLoading.value = true;
        errorMessage.value = null;
      }
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
      if (!silent) isLoading.value = false;
    } catch (e) {
      if (!silent) {
        isLoading.value = false;
        errorMessage.value = 'Failed to load books: $e';
      }
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

  void _onProgressUpdate(ReadingProgressUpdate update) {
    // Update the affected book's progress instantly.
    bookProgress[update.bookId] = update.bookProgressPercent;

    // If the currently shown "continue reading" book changed, refresh it.
    final cont = continueReading.value;
    if (cont != null && cont.book.id == update.bookId) {
      _refreshContinueReading();
    }
  }

  Future<void> _refreshContinueReading() async {
    final updated = await _loadContinueReading();
    if (updated != null) {
      continueReading.value = updated;
      // Ensure the progress map reflects the latest value as well.
      bookProgress[updated.book.id] = await _bookRepository.getBookProgressPercent(updated.book.id);
    }
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
