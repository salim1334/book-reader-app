import 'package:book_store/core/services/reading_progress_service.dart';
import 'package:book_store/data/local/models/book_local_models.dart';
import 'package:book_store/data/remote/sync_manager.dart';
import 'package:book_store/data/repositories/book_repository.dart';
import 'package:book_store/features/book_details/controllers/book_details_controller.dart';
import 'package:book_store/features/book_details/presentation/arguments/book_details_args.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../../helpers/mocks.dart';
import '../../helpers/test_setup.dart';

class _TestBookDetailsController extends BookDetailsController {
  final BookDetailsArgs _args;

  _TestBookDetailsController(this._args);

  @override
  Future<void> onInit() async {
    final args = _args;
    initialBook = args.book;
    book.value = args.book;
    await loadData();
  }
}

void main() {
  setupTestBinding();

  late MockBookRepository repository;
  late FakeSyncManager syncManager;
  late MockReadingProgressService progressService;

  setUp(() async {
    resetGetX();
    repository = MockBookRepository();
    syncManager = FakeSyncManager(
      FakeBookRemoteSource(),
      FakeChapterRemoteSource(),
      FakeDownloadManager(),
    );
    progressService = MockReadingProgressService();

    when(() => progressService.progressUpdates)
        .thenAnswer((_) => Stream<ReadingProgressUpdate>.empty());
    when(() => repository.favoriteVersion)
        .thenAnswer((_) => 0.obs);

    Get.put<BookRepository>(repository, permanent: true);
    Get.put<SyncManager>(syncManager, permanent: true);
    Get.put<ReadingProgressService>(progressService, permanent: true);
  });

  group('BookDetailsController', () {
    test('loadData populates book and chapters', () async {
      const book = LocalBook(
        id: 'b1',
        title: 'Book',
        type: LocalBookType.text,
        version: 1,
      );
      const chapters = [
        LocalChapter(id: 'c1', bookId: 'b1', title: 'Ch1', sortOrder: 0, version: 1),
        LocalChapter(id: 'c2', bookId: 'b1', title: 'Ch2', sortOrder: 1, version: 1),
      ];

      when(() => repository.getBook('b1')).thenAnswer((_) async => book);
      when(() => repository.getChapters('b1')).thenAnswer((_) async => chapters);
      when(() => repository.getBookProgressPercent('b1'))
          .thenAnswer((_) async => 0.5);
      when(() => repository.getChaptersProgressPercent('b1'))
          .thenAnswer((_) async => {'c1': 0.2, 'c2': 0.8});
      when(() => repository.isBookFavorite('b1')).thenAnswer((_) async => false);
      when(() => repository.isChapterFavorite(any()))
          .thenAnswer((_) async => false);

      syncManager.isOnlineResult = false;

      final controller = _TestBookDetailsController(BookDetailsArgs(book: book));
      Get.put(controller);
      await controller.loadData();

      expect(controller.book.value, book);
      expect(controller.chapters.length, 2);
      expect(controller.bookProgressPercent.value, 0.5);
      expect(controller.chapterProgress['c1'], 0.2);
      expect(controller.isLoading.value, false);
    });

    test('toggleBookFavorite updates state and repository', () async {
      const book = LocalBook(
        id: 'b1',
        title: 'Book',
        type: LocalBookType.text,
        version: 1,
      );

      when(() => repository.getBook('b1')).thenAnswer((_) async => book);
      when(() => repository.getChapters('b1')).thenAnswer((_) async => []);
      when(() => repository.getBookProgressPercent('b1'))
          .thenAnswer((_) async => 0.0);
      when(() => repository.getChaptersProgressPercent('b1'))
          .thenAnswer((_) async => {});
      when(() => repository.isBookFavorite('b1')).thenAnswer((_) async => false);
      when(() => repository.setBookFavorite('b1', true))
          .thenAnswer((_) async {});

      syncManager.isOnlineResult = false;

      final controller = _TestBookDetailsController(BookDetailsArgs(book: book));
      Get.put(controller);
      await controller.loadData();

      await controller.toggleBookFavorite();

      expect(controller.isBookFavorite.value, true);
      verify(() => repository.setBookFavorite('b1', true)).called(1);
    });

    test('downloadChapter delegates to sync manager and reloads', () async {
      const book = LocalBook(
        id: 'b1',
        title: 'Book',
        type: LocalBookType.text,
        version: 1,
      );
      const chapter = LocalChapter(
        id: 'c1',
        bookId: 'b1',
        title: 'Ch1',
        sortOrder: 0,
        version: 1,
      );

      when(() => repository.getBook('b1')).thenAnswer((_) async => book);
      when(() => repository.getChapters('b1'))
          .thenAnswer((_) async => [chapter]);
      when(() => repository.getBookProgressPercent('b1'))
          .thenAnswer((_) async => 0.0);
      when(() => repository.getChaptersProgressPercent('b1'))
          .thenAnswer((_) async => {});
      when(() => repository.isBookFavorite('b1')).thenAnswer((_) async => false);
      when(() => repository.isChapterFavorite('c1'))
          .thenAnswer((_) async => false);

      syncManager.isOnlineResult = false;

      final controller = _TestBookDetailsController(BookDetailsArgs(book: book));
      Get.put(controller);
      await controller.loadData();

      await controller.downloadChapter(chapter);

      expect(syncManager.downloadedChapters, ['c1']);
    });
  });
}
