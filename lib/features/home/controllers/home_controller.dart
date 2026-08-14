import 'dart:async';

import 'package:book_store/common/utils/snackbar_helper.dart';
import 'package:book_store/core/constants/app_texts.dart';
import 'package:book_store/core/exceptions/storage_exceptions.dart';
import 'package:book_store/core/services/reading_progress_service.dart';
import 'package:book_store/data/local/models/book_local_models.dart';
import 'package:book_store/data/local/services/bundled_content_seeder.dart';
import 'package:book_store/data/remote/sync_manager.dart';
import 'package:book_store/data/repositories/book_repository.dart';
import 'package:book_store/data/repositories/settings_repository.dart';
import 'package:book_store/features/book_details/presentation/arguments/book_details_args.dart';
import 'package:book_store/features/chapter_reader/presentation/arguments/chapter_reader_args.dart';
import 'package:book_store/features/main_navigation/controllers/main_navigation_controller.dart';
import 'package:book_store/features/home/domain/entities/continue_reading.dart';
import 'package:book_store/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final BookRepository _bookRepository = Get.find<BookRepository>();
  final SyncManager _syncManager = Get.find<SyncManager>();
  final SettingsRepository _settings = Get.find<SettingsRepository>();
  final ReadingProgressService _progressService =
      Get.find<ReadingProgressService>();

  final books = <LocalBook>[].obs;
  final continueReading = Rxn<ContinueReading>();
  final isLoading = true.obs;
  final errorMessage = Rxn<String>();
  final isOffline = false.obs;
  final isCheckingForBooks = false.obs;

  /// True when the library only contains bundled offline content, meaning the
  /// remote catalog has never been synced and more books may exist online.
  final showMoreBooksHint = false.obs;
  RxBool get offlineMode => _settings.offlineMode;
  final downloadingBookId = Rxn<String>();
  final downloadedBooks = <String, bool>{}.obs;
  final bookProgress = <String, double>{}.obs;
  final bookFavorites = <String, bool>{}.obs;
  
  /// Set of book IDs currently in the download queue (for batch downloads).
  final queuedBookIds = <String>{}.obs;
  
  /// The book ID currently being downloaded (for UI display).
  final currentDownloadingBookId = Rxn<String>();

  Worker? _offlineModeWorker;
  Worker? _autoDownloadWorker;
  Worker? _catalogSyncWorker;
  Worker? _selectedIndexWorker;
  Worker? _downloadQueueWorker;
  StreamSubscription<ReadingProgressUpdate>? _progressSubscription;
  @override
  Future<void> onInit() async {
    super.onInit();
    await initialize();
    _bindSettingWorkers();
    _bindReactiveListeners();
    _bindTabWorker();
    _bindDownloadQueueWorker();

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

  // if there's anychange in progress the home page will notify the screen to refresh
  // isMinifyEnabled = true isShrinkResources = true
  // void checkContinueReading() {
  //   _onProgressUpdate(_progressService.getCurrentProgress());
  // }

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

  void _bindTabWorker() {
    try {
      final mainNav = Get.find<MainNavigationController>();
      _selectedIndexWorker = ever(
        mainNav.selectedIndex,
        (index) {
          if (index == 0) {
            refreshContinueReading();
          }
        },
      );
    } catch (_) {
      // Main navigation may not be available in all environments.
    }
  }

  /// Binds a worker to listen for changes in the SyncManager's download queue
  /// and updates the UI state accordingly.
  void _bindDownloadQueueWorker() {
    _downloadQueueWorker = ever(
      _syncManager.queuedChapterIds,
      (_) {
        // Update queued book IDs based on which books have chapters in the queue
        final queuedBookIdSet = <String>{};
        for (final chapterId in _syncManager.queuedChapterIds) {
          // We need to get the book ID for each queued chapter
          // This is a simplified approach - in practice you might want to cache this
          unawaited(_getBookIdForChapter(chapterId).then((bookId) {
            if (bookId != null) {
              queuedBookIds.add(bookId);
            }
          }).catchError((e) {
            debugPrint('HomeController._bindDownloadQueueWorker error: $e');
          }));
        }
        // Update current downloading book ID
        final currentChapterId = _syncManager.currentDownloadingChapterId.value;
        if (currentChapterId != null) {
          unawaited(_getBookIdForChapter(currentChapterId).then((bookId) {
            currentDownloadingBookId.value = bookId;
          }).catchError((e) {
            debugPrint('HomeController._bindDownloadQueueWorker error: $e');
          }));
        } else {
          currentDownloadingBookId.value = null;
        }
      },
    );
  }

  Future<String?> _getBookIdForChapter(String chapterId) async {
    try {
      final chapter = await _bookRepository.getChapter(chapterId);
      return chapter?.bookId;
    } catch (e) {
      debugPrint('HomeController._getBookIdForChapter error: $e');
      return null;
    }
  }

  @override
  Future<void> onClose() async {
    _offlineModeWorker?.dispose();
    _autoDownloadWorker?.dispose();
    _catalogSyncWorker?.dispose();
    _selectedIndexWorker?.dispose();
    _downloadQueueWorker?.dispose();
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
        progress[book.id] = await _bookRepository.getBookProgressPercent(
          book.id,
        );
        favorites[book.id] = await _bookRepository.isBookFavorite(book.id);
      }

      final booksToShow = offlineOnly
          ? loadedBooks.where((book) => downloaded[book.id] == true).toList()
          : loadedBooks;

      books.value = booksToShow;
      _updateMoreBooksHint(loadedBooks);
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

  void _updateMoreBooksHint(List<LocalBook> loadedBooks) {
    final bundledIds = BundledContentSeeder.bundledBookIds;
    showMoreBooksHint.value = loadedBooks.isNotEmpty &&
        bundledIds.isNotEmpty &&
        loadedBooks.every((book) => bundledIds.contains(book.id));
  }

  /// Manual "Check for Books" action from the empty state. Verifies
  /// connectivity first and shows a friendly message when offline.
  Future<void> checkForBooks() async {
    if (isCheckingForBooks.value) return;
    isCheckingForBooks.value = true;
    try {
      final online = await _syncManager.isOnline();
      isOffline.value = !online;
      if (!online) {
        SnackbarHelper.show(AppTexts.homeNoInternetMessage);
        return;
      }

      await _syncManager.syncCatalog();
      await loadBooks();
    } catch (e) {
      SnackbarHelper.show(AppTexts.homeRefreshCatalogError);
      debugPrint('HomeController.checkForBooks error: $e');
    } finally {
      isCheckingForBooks.value = false;
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
      refreshContinueReading();
    }
  }

  Future<void> refreshContinueReading() async {
    final updated = await _loadContinueReading();
    if (updated != null) {
      continueReading.value = updated;
      // Ensure the progress map reflects the latest value as well.
      bookProgress[updated.book.id] = await _bookRepository
          .getBookProgressPercent(updated.book.id);
    }
  }

  Future<void> autoSync() async {
    final online = await _syncManager.isOnline();
    isOffline.value = !online || _settings.offlineMode.value;
    if (!online || _settings.offlineMode.value) return;

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
      SnackbarHelper.show(AppTexts.homeRefreshCatalogError);
    }
  }

  Future<void> downloadBook(LocalBook book) async {
    // Add to queue if another book download is in progress
    if (currentDownloadingBookId.value != null && 
        currentDownloadingBookId.value != book.id) {
      if (!queuedBookIds.contains(book.id)) {
        queuedBookIds.add(book.id);
      }
      // The download will be handled by the queue worker
      return;
    }
    
    currentDownloadingBookId.value = book.id;
    try {
      await _syncManager.downloadBook(book.id);
      await loadBooks();
      SnackbarHelper.show(AppTexts.homeBookDownloaded(book.title));
    } on StorageFullException catch (e) {
      SnackbarHelper.show(e.toString());
    } catch (e) {
      SnackbarHelper.show(AppTexts.homeDownloadFailed);
    } finally {
      currentDownloadingBookId.value = null;
      queuedBookIds.remove(book.id);
      // Process next queued book download if available
      _processNextQueuedBookDownload();
    }
  }

  /// Processes the next book in the download queue.
  void _processNextQueuedBookDownload() {
    if (queuedBookIds.isEmpty) return;
    
    final nextBookId = queuedBookIds.first;
    queuedBookIds.removeAt(0);
    
    // Find the book and trigger its download
    final nextBook = books.firstWhere(
      (b) => b.id == nextBookId,
      orElse: () => throw Exception('Book $nextBookId not found'),
    );
    
    unawaited(downloadBook(nextBook).catchError((e) {
      debugPrint('HomeController._processNextQueuedBookDownload error: $e');
    }));
  }

  Future<void> toggleBookFavorite(LocalBook book) async {
    final newValue = !(bookFavorites[book.id] ?? false);
    await _bookRepository.setBookFavorite(book.id, newValue);
    bookFavorites[book.id] = newValue;
  }

  void openBook(LocalBook book) {
    Get.toNamed(Routes.bookDetails, arguments: BookDetailsArgs(book: book));
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
