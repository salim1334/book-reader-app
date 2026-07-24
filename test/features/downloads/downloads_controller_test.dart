import 'package:book_store/data/local/models/book_local_models.dart';
import 'package:book_store/data/remote/sync_manager.dart';
import 'package:book_store/data/repositories/book_repository.dart';
import 'package:book_store/features/downloads/controllers/downloads_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../../helpers/mocks.dart';
import '../../helpers/test_setup.dart';

void main() {
  setupTestBinding();

  late MockBookRepository repository;
  late FakeSyncManager syncManager;

  setUp(() {
    resetGetX();
    repository = MockBookRepository();
    syncManager = FakeSyncManager(
      FakeBookRemoteSource(),
      FakeChapterRemoteSource(),
      FakeDownloadManager(),
    );

    Get.put<BookRepository>(repository, permanent: true);
    Get.put<SyncManager>(syncManager, permanent: true);
  });

  group('DownloadsController', () {
    test('loadData populates books, counts and queue', () async {
      const books = [
        LocalBook(id: 'b1', title: 'Book', type: LocalBookType.text, version: 1),
      ];
      const chapters = [
        LocalChapter(id: 'c1', bookId: 'b1', title: 'Ch1', sortOrder: 0, version: 1),
      ];
      const queue = [
        <String, Object?>{
          'chapter_id': 'c1',
          'book_id': 'b1',
          'status': 'PENDING',
          'progress': 0.0,
        }
      ];

      when(() => repository.getBooks()).thenAnswer((_) async => books);
      when(() => repository.getChapters('b1')).thenAnswer((_) async => chapters);
      when(() => repository.getDownloadQueue()).thenAnswer((_) async => queue);

      final controller = DownloadsController();
      Get.put(controller);
      await controller.loadData();

      expect(controller.books.length, 1);
      expect(controller.chapterCounts['b1'], 1);
      expect(controller.queue.length, 1);
      expect(controller.isLoading.value, false);
    });

    test('queueIcon returns correct icons', () {
      final controller = DownloadsController();
      expect(controller.queueIcon('COMPLETED'), isA<Icon>());
      expect(controller.queueIcon('FAILED'), isA<Icon>());
      expect(controller.queueIcon('DOWNLOADING'), isA<Icon>());
      expect(controller.queueIcon('PENDING'), isA<Icon>());
      expect(controller.queueIcon('UNKNOWN'), isA<Icon>());
    });

    test('retryChapter delegates to sync manager', () async {
      const book = LocalBook(
        id: 'b1',
        title: 'Book',
        type: LocalBookType.text,
        version: 1,
      );

      when(() => repository.getBooks()).thenAnswer((_) async => [book]);
      when(() => repository.getChapters('b1')).thenAnswer((_) async => []);
      when(() => repository.getDownloadQueue()).thenAnswer((_) async => []);

      final controller = DownloadsController();
      Get.put(controller);
      await controller.loadData();

      await controller.retryChapter('c1');

      expect(syncManager.downloadedChapters, ['c1']);
    });
  });
}
