import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:book_store/core/utils/asset_url.dart';
import 'package:book_store/data/local/daos/book_dao.dart';
import 'package:book_store/data/local/database_helper.dart';
import 'package:book_store/data/local/models/book_local_models.dart';
import 'package:book_store/data/remote/book_remote_source.dart';
import 'package:book_store/data/remote/chapter_remote_source.dart';
import 'package:book_store/data/remote/download_manager.dart';
import 'package:book_store/data/remote/models/remote_book.dart';
import 'package:book_store/data/remote/models/remote_chapter.dart';
import 'package:book_store/data/repositories/settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Coordinates fetching remote books, comparing versions, and updating local DB.
class SyncManager extends GetxService with WidgetsBindingObserver {
  final BookRemoteSource _bookRemoteSource;
  final ChapterRemoteSource _chapterRemoteSource;
  final DownloadManager _downloadManager;
  BookDao? _dao;

  SyncManager(
    this._bookRemoteSource,
    this._chapterRemoteSource,
    this._downloadManager,
  );

  static const _defaultSyncInterval = Duration(minutes: 15);
  static const _resumeDebounce = Duration(seconds: 3);

  Timer? _periodicSyncTimer;
  Timer? _resumeSyncTimer;

  /// Reactive flag showing when the last catalog-only background sync completed.
  final lastCatalogSyncAt = Rxn<DateTime>();

  /// Reactive flag indicating a background sync is currently running.
  final isBackgroundSyncing = false.obs;

  static Future<SyncManager> init() async {
    final manager = SyncManager(
      Get.find<BookRemoteSource>(),
      Get.find<ChapterRemoteSource>(),
      Get.find<DownloadManager>(),
    );
    await manager._ensureDb();
    return manager;
  }

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _startPeriodicSync();
    unawaited(backgroundCatalogSync());
  }

  @override
  void onClose() {
    _stopPeriodicSync();
    _resumeSyncTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startPeriodicSync();
      // Debounce to avoid multiple rapid syncs when the OS flutters lifecycle.
      _resumeSyncTimer?.cancel();
      _resumeSyncTimer = Timer(_resumeDebounce, backgroundCatalogSync);
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      _resumeSyncTimer?.cancel();
      _stopPeriodicSync();
    }
  }

  void _startPeriodicSync() {
    _stopPeriodicSync();
    _periodicSyncTimer = Timer.periodic(_defaultSyncInterval, (_) {
      backgroundCatalogSync();
    });
  }

  void _stopPeriodicSync() {
    _periodicSyncTimer?.cancel();
    _periodicSyncTimer = null;
  }

  /// Lightweight catalog-only sync suitable for background/periodic refresh.
  /// Does not trigger downloads and will not show user-facing errors.
  Future<void> backgroundCatalogSync() async {
    if (isBackgroundSyncing.value) return;

    final online = await isOnline();
    if (!online) return;

    final settings = Get.find<SettingsRepository>();
    if (settings.offlineMode.value) return;

    isBackgroundSyncing.value = true;
    try {
      await syncCatalog();
      lastCatalogSyncAt.value = DateTime.now();
    } catch (e) {
      debugPrint('SyncManager.backgroundCatalogSync error: $e');
    } finally {
      isBackgroundSyncing.value = false;
    }
  }

  Future<void> _ensureDb() async {
    _dao ??= BookDao(await DatabaseHelper.instance.database);
  }

  /// Simple online check by attempting a short DNS lookup.
  Future<bool> isOnline() async {
    try {
      await InternetAddress.lookup('example.com')
          .timeout(const Duration(seconds: 3));
      return true;
    } on SocketException catch (_) {
      return false;
    } on TimeoutException catch (_) {
      return false;
    } catch (_) {
      return false;
    }
  }

  final Rx<SyncState> syncState = SyncState.idle.obs;
  final RxString? currentDownload = RxString('');
  final RxMap<String, double> bookDownloadProgress = <String, double>{}.obs;
  final RxMap<String, double> chapterDownloadProgress = <String, double>{}.obs;

  /// Fetches the list of published remote books for this author.
  Future<List<RemoteBook>> fetchRemoteBooks() async {
    return _bookRemoteSource.fetchBooks();
  }

  /// Fetches remote metadata and stores it locally without downloading any
  /// chapter content or media. This keeps the Home Screen catalog up to date.
  Future<void> syncCatalog() async {
    await _ensureDb();
    syncState.value = SyncState.syncing;
    try {
      final remoteBooks = await _bookRemoteSource.fetchBooks();
      for (final remoteBook in remoteBooks) {
        await _syncBookMetadata(remoteBook);
      }
    } finally {
      syncState.value = SyncState.idle;
    }
  }

  /// Fetches the latest book metadata and chapter list without downloading
  /// any chapter content.
  Future<RemoteBook> fetchAndSyncBookMetadata(String bookId) async {
    await _ensureDb();
    syncState.value = SyncState.syncing;
    try {
      final remoteBook = await _bookRemoteSource.fetchBook(bookId);
      await _syncBookMetadata(remoteBook);
      return remoteBook;
    } finally {
      syncState.value = SyncState.idle;
    }
  }

  /// Downloads an entire book (metadata, cover, and every chapter).
  Future<void> downloadBook(String bookId) async {
    await _ensureDb();
    syncState.value = SyncState.downloading;
    bookDownloadProgress[bookId] = 0.0;
    try {
      final remoteBook = await _bookRemoteSource.fetchBook(bookId);
      if (!remoteBook.isPublished) {
        throw Exception('Book $bookId is not published');
      }
      await _syncBookMetadata(
        remoteBook,
        downloadCover: true,
        updateVersions: true,
      );

      await _downloadCover(bookId, remoteBook.coverImage);

      final totalChapters = remoteBook.chapters.length;
      for (var i = 0; i < totalChapters; i++) {
        final summary = remoteBook.chapters[i];
        bookDownloadProgress[bookId] = i / totalChapters;
        await downloadChapter(
          summary.id,
          onProgress: (chapterProgress) {
            bookDownloadProgress[bookId] = (i + chapterProgress) / totalChapters;
          },
        );
      }
      bookDownloadProgress[bookId] = 1.0;
    } finally {
      syncState.value = SyncState.idle;
      currentDownload?.value = '';
    }
  }

  /// Re-downloads only chapters whose version is newer than the local copy,
  /// along with any updated book metadata and cover image.
  Future<void> updateBook(String bookId) async {
    await _ensureDb();
    syncState.value = SyncState.downloading;
    bookDownloadProgress[bookId] = 0.0;
    try {
      final remoteBook = await _bookRemoteSource.fetchBook(bookId);
      if (!remoteBook.isPublished) {
        throw Exception('Book $bookId is not published');
      }
      await _syncBookMetadata(
        remoteBook,
        downloadCover: true,
        updateVersions: false,
      );

      final localChapters = await _dao!.getChapters(bookId);
      final localChapterMap = {for (final c in localChapters) c.id: c};

      final totalChapters = remoteBook.chapters.length;
      var processedChapters = 0;
      for (final summary in remoteBook.chapters) {
        final local = localChapterMap[summary.id];
        if (local == null || !local.isDownloaded || summary.version > local.version) {
          await downloadChapter(
            summary.id,
            onProgress: (chapterProgress) {
              bookDownloadProgress[bookId] = (processedChapters + chapterProgress) / totalChapters;
            },
          );
        }
        processedChapters++;
        bookDownloadProgress[bookId] = processedChapters / totalChapters;
      }

      await _downloadCover(bookId, remoteBook.coverImage);
      await _dao!.updateBookVersion(bookId, remoteBook.version);
      bookDownloadProgress[bookId] = 1.0;
    } finally {
      syncState.value = SyncState.idle;
      currentDownload?.value = '';
    }
  }

  /// Downloads the content and media for a single chapter and marks it as
  /// downloaded so it can be read offline.
  Future<void> downloadChapter(
    String chapterId, {
    void Function(double progress)? onProgress,
  }) async {
    await _ensureDb();
    syncState.value = SyncState.downloading;
    currentDownload?.value = 'Fetching chapter...';
    chapterDownloadProgress[chapterId] = 0.0;
    try {
      final chapter = await _chapterRemoteSource.fetchPages(chapterId);

      // Remove stale assets before re-downloading (important for updates).
      await _deleteChapterAssets(chapterId);

      // Persist text content for TEXT chapters.
      await _persistTextContent(chapter);

      // Download images and audio files.
      final totalAssets = (chapter.pages?.length ?? 0) + (chapter.audios?.length ?? 0);
      var completedAssets = 0;
      void report() {
        final progress = totalAssets == 0 ? 1.0 : completedAssets / totalAssets;
        chapterDownloadProgress[chapterId] = progress;
        onProgress?.call(progress);
      }
      report();
      await _downloadMedia(
        chapter,
        onAssetComplete: () {
          completedAssets++;
          report();
        },
      );
      chapterDownloadProgress[chapterId] = 1.0;
      onProgress?.call(1.0);

      // Record the downloaded content version.
      final localChapter = LocalChapter(
        id: chapter.id,
        bookId: chapter.bookId,
        title: chapter.title,
        sortOrder: chapter.orderIndex,
        version: chapter.version,
      );
      await _dao!.updateChapterMetadata(localChapter);
      await _dao!.markChapterDownloaded(chapterId, true);
    } finally {
      syncState.value = SyncState.idle;
      currentDownload?.value = '';
    }
  }

  Future<void> _syncBookMetadata(
    RemoteBook book, {
    bool downloadCover = false,
    bool updateVersions = false,
  }) async {
    await _ensureDb();
    final existing = await _dao!.getBook(book.id);

    if (existing == null) {
      final localBook = LocalBook(
        id: book.id,
        title: book.title,
        description: book.description,
        coverUrl: book.coverImage,
        type: LocalBookTypeX.fromDb(book.type),
        swipeDirection: SwipeDirectionX.fromDb(book.swipeDirection),
        version: book.version,
      );
      await _dao!.insertBook(localBook);
    } else {
      // Keep an existing downloaded cover unless we are explicitly downloading it.
      String? coverUrl;
      if (downloadCover) {
        coverUrl = book.coverImage;
      } else if (existing.coverUrl != null && !isRemoteCoverUrl(existing.coverUrl)) {
        coverUrl = existing.coverUrl;
      } else {
        coverUrl = book.coverImage;
      }

      final localBook = LocalBook(
        id: book.id,
        title: book.title,
        description: book.description,
        coverUrl: coverUrl,
        type: LocalBookTypeX.fromDb(book.type),
        swipeDirection: SwipeDirectionX.fromDb(book.swipeDirection),
        version: updateVersions ? book.version : existing.version,
      );
      if (updateVersions) {
        await _dao!.updateBookMetadata(localBook);
      } else {
        await _dao!.updateBookInfo(localBook);
      }
    }

    for (final summary in book.chapters) {
      final existingChapter = await _dao!.getChapter(summary.id);
      final localChapter = LocalChapter(
        id: summary.id,
        bookId: book.id,
        title: summary.title,
        description: summary.description,
        sortOrder: summary.orderIndex,
        version: summary.version,
      );
      if (existingChapter == null) {
        await _dao!.insertChapter(localChapter);
      } else {
        // Update title/order/description, but keep the existing content version
        // unless we are explicitly updating versions (e.g. during a full sync).
        if (updateVersions) {
          await _dao!.updateChapterMetadata(localChapter);
        } else {
          await _dao!.updateChapterInfo(localChapter);
        }
      }
    }
  }

  Future<void> _downloadCover(String bookId, String? coverImage) async {
    if (coverImage == null || coverImage.isEmpty) return;
    final localPath = await _downloadManager.downloadAsset(
      assetType: 'images',
      bookId: bookId,
      chapterId: 'cover',
      remotePath: coverImage,
    );
    await _dao!.updateBookCover(bookId, localPath);
  }

  Future<void> _persistTextContent(RemoteChapter chapter) async {
    if (chapter.texts?.isNotEmpty != true) return;

    final contentText = chapter.texts!.map((t) => t.content).join('\n\n');

    final segments = chapter.texts!
        .where((t) => t.audioStartTime != null && t.audioEndTime != null)
        .map(
          (t) => TextSegment(
            content: t.content,
            startSeconds: t.audioStartTime,
            endSeconds: t.audioEndTime,
          ),
        )
        .toList();

    final segmentsJson = segments.isNotEmpty
        ? jsonEncode(segments.map((s) => s.toJson()).toList())
        : null;

    await _dao!.updateChapterContent(
      chapter.id,
      contentText: contentText,
      contentSegmentsJson: segmentsJson,
    );
  }

  Future<void> _downloadMedia(
    RemoteChapter chapter, {
    void Function()? onAssetComplete,
  }) async {
    final bookId = chapter.bookId;

    if (chapter.pages != null) {
      for (final page in chapter.pages!) {
        final localPath = await _downloadImage(
          bookId,
          chapter.id,
          page.imagePath,
        );
        await _dao!.insertDownloadedAsset(
          chapterId: chapter.id,
          assetType: 'IMAGE',
          filePath: localPath,
          sortOrder: page.orderIndex,
          audioStartTime: page.audioStartTime,
          audioEndTime: page.audioEndTime,
        );
        onAssetComplete?.call();
      }
    }

    if (chapter.audios != null) {
      for (final audio in chapter.audios!) {
        final localPath = await _downloadAudio(
          bookId,
          chapter.id,
          audio.audioPath,
        );
        await _dao!.insertDownloadedAsset(
          chapterId: chapter.id,
          assetType: 'AUDIO',
          filePath: localPath,
        );
        onAssetComplete?.call();
      }
    }
  }

  Future<void> _deleteChapterAssets(String chapterId) async {
    final assets = await _dao!.getDownloadedAssets(chapterId);
    for (final row in assets) {
      final path = row['file_path']?.toString();
      if (path != null && path.isNotEmpty) {
        await _downloadManager.deleteAsset(path);
      }
    }
    await _dao!.deleteDownloadedAssets(chapterId);
  }

  Future<String> _downloadImage(
    String bookId,
    String chapterId,
    String remotePath,
  ) async {
    currentDownload?.value = 'Downloading image...';
    return _downloadManager.downloadAsset(
      assetType: 'images',
      bookId: bookId,
      chapterId: chapterId,
      remotePath: remotePath,
      onProgress: (received, total) {
        currentDownload?.value =
            'Image: ${(received / total * 100).toStringAsFixed(0)}%';
      },
    );
  }

  Future<String> _downloadAudio(
    String bookId,
    String chapterId,
    String remotePath,
  ) async {
    currentDownload?.value = 'Downloading audio...';
    return _downloadManager.downloadAsset(
      assetType: 'audio',
      bookId: bookId,
      chapterId: chapterId,
      remotePath: remotePath,
      onProgress: (received, total) {
        currentDownload?.value =
            'Audio: ${(received / total * 100).toStringAsFixed(0)}%';
      },
    );
  }
}

enum SyncState { idle, syncing, downloading, error }
