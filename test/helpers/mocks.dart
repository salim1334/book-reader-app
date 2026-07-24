import 'package:book_store/core/services/audio_player_service.dart';
import 'package:book_store/core/services/notification_service.dart';
import 'package:book_store/core/services/reading_progress_service.dart';
import 'package:book_store/data/local/daos/book_dao.dart';
import 'package:book_store/data/local/daos/settings_dao.dart';
import 'package:book_store/data/local/models/book_local_models.dart';
import 'package:book_store/data/remote/book_remote_source.dart';
import 'package:book_store/data/remote/chapter_remote_source.dart';
import 'package:book_store/data/remote/download_manager.dart';
import 'package:book_store/data/remote/models/remote_book.dart';
import 'package:book_store/data/remote/models/remote_chapter.dart';
import 'package:book_store/data/remote/sync_manager.dart';
import 'package:book_store/data/repositories/book_repository.dart';
import 'package:book_store/data/repositories/settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:mocktail/mocktail.dart';

export 'package:mocktail/mocktail.dart';

/// Fallback values so mocktail can build `any()` matchers for the types used
/// in the stubbed methods.
void registerMocktailFallbacks() {
  registerFallbackValue(
    LocalBook(id: 'b1', title: 'Book', type: LocalBookType.text, version: 1),
  );
  registerFallbackValue(
    LocalChapter(
      id: 'c1',
      bookId: 'b1',
      title: 'Chapter',
      sortOrder: 0,
      version: 1,
    ),
  );
  registerFallbackValue(
    RemoteBook(
      id: 'b1',
      title: 'Book',
      type: 'TEXT',
      version: 1,
      author: RemoteAuthor(id: 'a1', name: 'Author'),
    ),
  );
  registerFallbackValue(RemoteAuthor(id: 'a1', name: 'Author'));
  registerFallbackValue(
    RemoteChapter(
      id: 'c1',
      bookId: 'b1',
      title: 'Chapter',
      orderIndex: 0,
      version: 1,
    ),
  );
  registerFallbackValue(
    AudioItem(id: 'audio_1', title: 'Audio', path: '/tmp/audio.mp3'),
  );
  registerFallbackValue(AudioQueue(items: const []));
  registerFallbackValue(ThemeMode.system);
  registerFallbackValue('');
  registerFallbackValue(0);
  registerFallbackValue(0.0);
  registerFallbackValue(true);
}

// ─── mocktail mocks ─────────────────────────────────────────────────────────

class MockBookDao extends Mock implements BookDao {}

class MockSettingsDao extends Mock implements SettingsDao {}

class MockBookRepository extends Mock implements BookRepository {}

class MockSettingsRepository extends Mock implements SettingsRepository {}

class MockAudioPlayerService extends Mock implements AudioPlayerService {}

class FakeAudioPlayerService extends AudioPlayerService {
  @override
  Future<AudioPlayerService> init() async => this;

  @override
  Future<void> playQueue(AudioQueue queue, {String? sourceTitle, String? sourceSubtitle, String? sourceArtUri, double? initialSpeed}) async {}

  @override
  Future<void> play() async {}

  @override
  Future<void> pause() async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> seek(Duration pos) async {}

  @override
  Future<void> skipToNext() async {}

  @override
  Future<void> skipToPrevious() async {}

  @override
  Future<void> setSpeed(double value) async {}

  @override
  Future<void> setVolume(double value) async {}

  @override
  Future<void> togglePlayPause() async {}

  @override
  bool get isInitialized => true;

  @override
  bool isCurrentBookChapter(LocalBook book, LocalChapter chapter) => false;

  @override
  Future<void> persistCurrentProgress() async {}

  @override
  void onClose() {}
}

class MockReadingProgressService extends Mock
    implements ReadingProgressService {}

class MockNotificationService extends Mock implements NotificationService {}

// ─── lightweight fakes for concrete remote classes ──────────────────────────

class FakeBookRemoteSource extends BookRemoteSource {
  List<RemoteBook> books = const [];
  final Map<String, RemoteBook> _booksById = {};

  void addBook(RemoteBook book) {
    _booksById[book.id] = book;
    books = _booksById.values.toList();
  }

  @override
  Future<List<RemoteBook>> fetchBooks() async => books;

  @override
  Future<RemoteBook> fetchBook(String bookId) async {
    final book = _booksById[bookId];
    if (book == null) throw Exception('Book $bookId not found');
    return book;
  }
}

class FakeChapterRemoteSource extends ChapterRemoteSource {
  final Map<String, RemoteChapter> _chapters = {};

  void addChapter(RemoteChapter chapter) => _chapters[chapter.id] = chapter;

  @override
  Future<RemoteChapter> fetchChapter(String chapterId) async {
    final chapter = _chapters[chapterId];
    if (chapter == null) throw Exception('Chapter $chapterId not found');
    return chapter;
  }

  @override
  Future<RemoteChapter> fetchPages(String chapterId) async =>
      fetchChapter(chapterId);
}

class FakeDownloadManager extends DownloadManager {
  final Map<String, String> _pathByRemote = {};

  void stubDownload({
    required String bookId,
    required String chapterId,
    required String assetType,
    required String remotePath,
    required String localPath,
  }) {
    _pathByRemote['$assetType/$bookId/$chapterId/$remotePath'] = localPath;
  }

  @override
  Future<String> downloadAsset({
    required String assetType,
    required String bookId,
    required String chapterId,
    required String remotePath,
    void Function(int received, int total)? onProgress,
  }) async {
    final key = '$assetType/$bookId/$chapterId/$remotePath';
    if (_pathByRemote.containsKey(key)) return _pathByRemote[key]!;
    return '/downloads/$assetType/$bookId/$chapterId/${remotePath.split('/').last}';
  }

  @override
  Future<void> deleteAsset(String localPath) async {}

  @override
  Future<void> deleteBookAssets(String bookId) async {}

  @override
  Future<void> clearDownloads() async {}
}

// ─── SyncManager fake that disables lifecycle side-effects ─────────────────

class FakeSyncManager extends SyncManager {
  FakeSyncManager(
    super.bookRemoteSource,
    super.chapterRemoteSource,
    super.downloadManager, {
    super.dao,
  });

  bool isOnlineResult = true;
  bool delegateSyncCatalog = false;
  bool delegateDownloadChapter = false;
  int syncCatalogCallCount = 0;
  final List<String> updatedBooks = [];
  final List<String> downloadedChapters = [];
  final Map<String, RemoteBook> bookMetadata = {};

  @override
  Future<bool> isOnline() async => isOnlineResult;

  @override
  Future<void> syncCatalog() async {
    syncCatalogCallCount++;
    if (delegateSyncCatalog) {
      return super.syncCatalog();
    }
    lastCatalogSyncAt.value = DateTime.now();
  }

  @override
  Future<RemoteBook> fetchAndSyncBookMetadata(String bookId) async {
    if (bookMetadata.containsKey(bookId)) return bookMetadata[bookId]!;
    return super.fetchAndSyncBookMetadata(bookId);
  }

  @override
  Future<void> updateBook(String bookId) async {
    updatedBooks.add(bookId);
  }

  @override
  Future<void> downloadChapter(
    String chapterId, {
    void Function(double progress)? onProgress,
  }) async {
    downloadedChapters.add(chapterId);
    if (delegateDownloadChapter) {
      return super.downloadChapter(chapterId, onProgress: onProgress);
    }
  }

  @override
  void onInit() {
    // Skip WidgetsBinding observer and periodic timer setup.
  }

  @override
  void onClose() {
    // Skip cleanup to avoid observer/timer errors in unit tests.
  }
}
