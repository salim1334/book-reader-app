import 'dart:async';

import 'package:book_store/common/utils/snackbar_helper.dart';
import 'package:book_store/core/exceptions/storage_exceptions.dart';
import 'package:book_store/core/services/reading_progress_service.dart';
import 'package:book_store/data/local/models/book_local_models.dart';
import 'package:book_store/data/remote/models/remote_book.dart';
import 'package:book_store/data/remote/sync_manager.dart';
import 'package:book_store/data/repositories/book_repository.dart';
import 'package:book_store/features/book_details/presentation/arguments/book_details_args.dart';
import 'package:book_store/features/chapter_reader/presentation/arguments/chapter_reader_args.dart';
import 'package:book_store/routes/app_routes.dart';
import 'package:book_store/core/constants/app_texts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BookDetailsController extends GetxController {
  final BookRepository _repository = Get.find<BookRepository>();
  final SyncManager _syncManager = Get.find<SyncManager>();
  final ReadingProgressService _progressService =
      Get.find<ReadingProgressService>();

  late final LocalBook initialBook;

  final book = Rxn<LocalBook>();
  final chapters = <LocalChapter>[].obs;
  final isLoading = true.obs;
  final errorMessage = Rxn<String>();
  final remoteBook = Rxn<RemoteBook>();
  final hasUpdate = false.obs;
  final outdatedChapterIds = <String>[].obs;
  final downloadingChapterId = Rxn<String>();
  final isOffline = false.obs;
  final bookProgressPercent = 0.0.obs;
  final chapterProgress = <String, double>{}.obs;
  final isBookFavorite = false.obs;
  final chapterFavoriteStates = <String, bool>{}.obs;

  Worker? _catalogSyncWorker;
  StreamSubscription<ReadingProgressUpdate>? _progressSubscription;

  @override
  Future<void> onInit() async {
    super.onInit();
    final args = Get.arguments as BookDetailsArgs?;
    if (args == null) {
      errorMessage.value = 'No book provided';
      isLoading.value = false;
      return;
    }
    initialBook = args.book;
    book.value = args.book;
    await loadData();
    _bindReactiveListeners();
  }

  Future<void> loadData({bool silent = false}) async {
    try {
      if (!silent) isLoading.value = true;
      errorMessage.value = null;

      final localBook = await _repository.getBook(initialBook.id);
      final localChapters = await _repository.getChapters(initialBook.id);

      if (localBook != null) book.value = localBook;
      chapters.value = localChapters;
      await _loadProgress();
      await _loadFavoriteStates();

      // Skip the remote round-trip during silent background refreshes.
      if (!silent) {
        final online = await _syncManager.isOnline();
        isOffline.value = !online;

        if (online) {
          RemoteBook? fetchedRemoteBook;
          try {
            fetchedRemoteBook = await _syncManager.fetchAndSyncBookMetadata(
              initialBook.id,
            );
          } catch (e) {
            debugPrint('Remote fetch failed, using offline source:  ');
            isOffline.value = true;
          }

          if (fetchedRemoteBook != null) {
            remoteBook.value = fetchedRemoteBook;

            final updatedBook = await _repository.getBook(initialBook.id);
            final updatedChapters = await _repository.getChapters(
              initialBook.id,
            );
            if (updatedBook != null) book.value = updatedBook;
            chapters.value = updatedChapters;
            await _loadProgress();

            outdatedChapterIds.value = _findOutdatedChapterIds(
              fetchedRemoteBook,
              chapters,
            );
            hasUpdate.value =
                fetchedRemoteBook.version > book.value!.version ||
                outdatedChapterIds.isNotEmpty;
          }
        }
      }

      if (!silent) isLoading.value = false;
    } catch (e) {
      if (!silent) isLoading.value = false;
      if (book.value == null && !silent) {
        errorMessage.value = 'Failed to load book details:  ';
      }
      debugPrint('BookDetailsController.loadData error:  ');
    }
  }

  Future<void> _loadProgress() async {
    bookProgressPercent.value = await _repository.getBookProgressPercent(
      initialBook.id,
    );
    chapterProgress.assignAll(
      await _repository.getChaptersProgressPercent(initialBook.id),
    );
  }

  Future<void> _loadFavoriteStates() async {
    isBookFavorite.value = await _repository.isBookFavorite(initialBook.id);
    final states = <String, bool>{};
    for (final chapter in chapters) {
      states[chapter.id] = await _repository.isChapterFavorite(chapter.id);
    }
    chapterFavoriteStates.assignAll(states);
  }

  Future<void> toggleBookFavorite() async {
    final newValue = !isBookFavorite.value;
    final bookId = book.value?.id ?? initialBook.id;
    await _repository.setBookFavorite(bookId, newValue);
    isBookFavorite.value = newValue;
  }

  Future<void> toggleChapterFavorite(String chapterId) async {
    final newValue = !(chapterFavoriteStates[chapterId] ?? false);
    await _repository.setChapterFavorite(chapterId, newValue);
    chapterFavoriteStates[chapterId] = newValue;
  }

  List<String> _findOutdatedChapterIds(
    RemoteBook remote,
    List<LocalChapter> localChapters,
  ) {
    final localMap = {for (final c in localChapters) c.id: c};
    final outdated = <String>[];
    for (final summary in remote.chapters) {
      final local = localMap[summary.id];
      if (local != null && summary.version > local.version) {
        outdated.add(summary.id);
      }
    }
    return outdated;
  }

  Future<void> updateBook() async {
    isLoading.value = true;
    try {
      await _syncManager.updateBook(book.value!.id);
      await loadData();
      SnackbarHelper.show(AppTexts.bookDetailsUpdateSuccess);
    } on StorageFullException catch (e) {
      SnackbarHelper.show(e.toString());
    } catch (e) {
      SnackbarHelper.show(AppTexts.bookDetailsUpdateError);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> downloadChapter(LocalChapter chapter) async {
    if (downloadingChapterId.value == chapter.id) return;
    downloadingChapterId.value = chapter.id;
    try {
      await _syncManager.downloadChapter(chapter.id);
      SnackbarHelper.show(AppTexts.bookDetailsChapterDownloaded(chapter.title));
    } on StorageFullException catch (e) {
      SnackbarHelper.show(e.toString());
    } catch (e) {
      SnackbarHelper.show(AppTexts.bookDetailsDownloadError);
    } finally {
      downloadingChapterId.value = null;
      await loadData();
    }
  }

  void openChapter(LocalChapter chapter) {
    if (!chapter.isDownloaded) {
      SnackbarHelper.show(AppTexts.bookDetailsChapterNotDownloaded);
      return;
    }
    Get.toNamed(
      Routes.chapterReader,
      arguments: ChapterReaderArgs(book: book.value!, chapter: chapter),
    );
  }

  @override
  Future<void> refresh() => loadData();

  void _bindReactiveListeners() {
    _catalogSyncWorker = ever(
      _syncManager.lastCatalogSyncAt,
      (_) => loadData(silent: true),
    );
    _progressSubscription = _progressService.progressUpdates.listen(
      _onProgressUpdate,
      onError: (e) =>
          debugPrint('BookDetailsController progress stream error:  '),
    );
  }

  void _onProgressUpdate(ReadingProgressUpdate update) {
    if (update.bookId != initialBook.id) return;

    // Instantly update the affected chapter and overall book progress.
    chapterProgress[update.chapterId] = update.chapterProgressPercent;
    bookProgressPercent.value = update.bookProgressPercent;
  }

  @override
  Future<void> onClose() async {
    _catalogSyncWorker?.dispose();
    await _progressSubscription?.cancel();
    super.onClose();
  }
}
