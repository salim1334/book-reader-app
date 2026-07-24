import 'dart:async';

import 'package:book_store/core/services/reading_progress_service.dart';
import 'package:book_store/data/local/models/book_local_models.dart';
import 'package:book_store/data/remote/models/remote_book.dart';
import 'package:book_store/data/remote/sync_manager.dart';
import 'package:book_store/data/repositories/book_repository.dart';
import 'package:book_store/data/repositories/settings_repository.dart';
import 'package:book_store/features/home/controllers/home_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../../helpers/mocks.dart';
import '../../helpers/test_setup.dart';

void main() {
  setupTestBinding();

  late MockBookRepository repository;
  late FakeBookRemoteSource bookRemote;
  late FakeChapterRemoteSource chapterRemote;
  late FakeDownloadManager downloadManager;
  late FakeSyncManager syncManager;
  late SettingsRepository settings;
  late MockReadingProgressService progressService;

  setUp(() async {
    resetGetX();
    repository = MockBookRepository();
    progressService = MockReadingProgressService();
    bookRemote = FakeBookRemoteSource();
    chapterRemote = FakeChapterRemoteSource();
    downloadManager = FakeDownloadManager();
    syncManager = FakeSyncManager(
      bookRemote,
      chapterRemote,
      downloadManager,
    );

    final settingsDao = MockSettingsDao();
    when(() => settingsDao.getString('theme_mode'))
        .thenAnswer((_) async => null);
    for (final key in [
      'font_size',
      'font_size_slider',
      'auto_scroll',
      'default_speed',
      'auto_play_next',
      'offline_mode',
      'auto_download',
      'notify_new_books',
      'notify_updates',
    ]) {
      when(() => settingsDao.getString(key)).thenAnswer((_) async => null);
    }
    when(
      () => settingsDao.getBool(any(), defaultValue: any(named: 'defaultValue')),
    ).thenAnswer((_) async => false);
    when(() => settingsDao.getDouble(any())).thenAnswer((_) async => null);
    settings = SettingsRepository(dao: settingsDao);
    await settings.onInit();

    final progressController = StreamController<ReadingProgressUpdate>.broadcast();
    when(() => progressService.progressUpdates)
        .thenAnswer((_) => progressController.stream);

    when(() => repository.favoriteVersion)
        .thenAnswer((_) => 0.obs);
    when(() => repository.getBooks()).thenAnswer((_) async => []);
    when(() => repository.getLastReadingProgress())
        .thenAnswer((_) async => null);

    Get.put<BookRepository>(repository, permanent: true);
    Get.put<SyncManager>(syncManager, permanent: true);
    Get.put<SettingsRepository>(settings, permanent: true);
    Get.put<ReadingProgressService>(progressService, permanent: true);
  });

  tearDown(() {
    syncManager.onClose();
  });

  group('HomeController', () {
    test('loadBooks populates books, progress and favorites', () async {
      const books = [
        LocalBook(id: 'b1', title: 'Book 1', type: LocalBookType.text, version: 1),
        LocalBook(id: 'b2', title: 'Book 2', type: LocalBookType.image, version: 1),
      ];
      const chapters = [
        LocalChapter(id: 'c1', bookId: 'b1', title: 'Ch1', sortOrder: 0, version: 1, isDownloaded: true),
      ];

      when(() => repository.getBooks()).thenAnswer((_) async => books);
      when(() => repository.getChapters('b1')).thenAnswer((_) async => chapters);
      when(() => repository.getChapters('b2')).thenAnswer((_) async => []);
      when(() => repository.getBookProgressPercent(any()))
          .thenAnswer((_) async => 1.0);
      when(() => repository.isBookFavorite('b1')).thenAnswer((_) async => true);
      when(() => repository.isBookFavorite('b2')).thenAnswer((_) async => false);

      final controller = HomeController();
      Get.put(controller);
      await controller.loadBooks();

      expect(controller.books.length, 2);
      expect(controller.bookProgress['b1'], 1.0);
      expect(controller.bookFavorites['b1'], true);
      expect(controller.downloadedBooks['b1'], true);
      expect(controller.isLoading.value, false);
    });

    test('offline mode filters downloaded books', () async {
      const books = [
        LocalBook(id: 'b1', title: 'Book 1', type: LocalBookType.text, version: 1),
        LocalBook(id: 'b2', title: 'Book 2', type: LocalBookType.text, version: 1),
      ];
      const chapters = [
        LocalChapter(id: 'c1', bookId: 'b1', title: 'Ch1', sortOrder: 0, version: 1, isDownloaded: true),
      ];

      when(() => repository.getBooks()).thenAnswer((_) async => books);
      when(() => repository.getChapters('b1')).thenAnswer((_) async => chapters);
      when(() => repository.getChapters('b2')).thenAnswer((_) async => []);
      when(() => repository.getBookProgressPercent(any()))
          .thenAnswer((_) async => 0.0);
      when(() => repository.isBookFavorite(any())).thenAnswer((_) async => false);

      settings.offlineMode.value = true;

      final controller = HomeController();
      Get.put(controller);
      await controller.loadBooks();

      expect(controller.books.length, 1);
      expect(controller.books.first.id, 'b1');
    });

    test('autoSync syncs catalog and downloads when auto download is enabled', () async {
      const books = [
        LocalBook(id: 'b1', title: 'Book 1', type: LocalBookType.text, version: 1),
      ];
      const chapters = [
        LocalChapter(id: 'c1', bookId: 'b1', title: 'Ch1', sortOrder: 0, version: 1, isDownloaded: true),
      ];

      when(() => repository.getBooks()).thenAnswer((_) async => books);
      when(() => repository.getChapters('b1')).thenAnswer((_) async => chapters);
      when(() => repository.getBookProgressPercent(any()))
          .thenAnswer((_) async => 0.0);
      when(() => repository.isBookFavorite(any())).thenAnswer((_) async => false);

      bookRemote.books = books.map((b) => RemoteBook(
            id: b.id,
            title: b.title,
            type: 'TEXT',
            version: 1,
            author: RemoteAuthor(id: 'a1', name: 'Author'),
            published: true,
            chapters: [],
          )).toList();

      settings.autoDownload.value = true;

      final controller = HomeController();
      Get.put(controller);

      await controller.autoSync();

      expect(controller.isOffline.value, false);
    });
  });
}
