import 'dart:async';

import 'package:book_store/core/services/reading_progress_service.dart';
import 'package:book_store/data/repositories/book_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../../helpers/mocks.dart';
import '../../helpers/test_setup.dart';

void main() {
  setupTestBinding();

  late MockBookRepository repository;
  late ReadingProgressService service;

  setUp(() {
    resetGetX();
    repository = MockBookRepository();
    when(() => repository.saveProgress(
          bookId: any(named: 'bookId'),
          chapterId: any(named: 'chapterId'),
          lastPositionMs: any(named: 'lastPositionMs'),
          lastPageIndex: any(named: 'lastPageIndex'),
          chapterProgressPercent: any(named: 'chapterProgressPercent'),
        )).thenAnswer((_) async {});
    Get.put<BookRepository>(repository, permanent: true);
    service = ReadingProgressService();
  });

  tearDown(() async {
    await service.dispose();
  });

  group('ReadingProgressService', () {
    test('saveProgress persists and emits an update when page changes', () async {
      when(() => repository.getBookProgressPercent('b1'))
          .thenAnswer((_) async => 0.25);

      final updates = <ReadingProgressUpdate>[];
      service.progressUpdates.listen(updates.add);

      await service.saveProgress(
        bookId: 'b1',
        chapterId: 'c1',
        lastPositionMs: 5000,
        lastPageIndex: 2,
        chapterProgressPercent: 0.5,
      );

      await pumpEventQueue();

      expect(updates.length, 1);
      final update = updates.first;
      expect(update.bookId, 'b1');
      expect(update.chapterId, 'c1');
      expect(update.lastPageIndex, 2);
      expect(update.chapterProgressPercent, 0.5);
      expect(update.bookProgressPercent, 0.25);

      verify(() => repository.saveProgress(
            bookId: 'b1',
            chapterId: 'c1',
            lastPositionMs: 5000,
            lastPageIndex: 2,
            chapterProgressPercent: 0.5,
          )).called(1);
    });

    test('saveProgress persists but does not emit duplicate visual progress', () async {
      when(() => repository.getBookProgressPercent('b1'))
          .thenAnswer((_) async => 0.0);

      final updates = <ReadingProgressUpdate>[];
      service.progressUpdates.listen(updates.add);

      await service.saveProgress(
        bookId: 'b1',
        chapterId: 'c1',
        lastPositionMs: 1000,
        lastPageIndex: 1,
        chapterProgressPercent: 0.25,
      );

      await service.saveProgress(
        bookId: 'b1',
        chapterId: 'c1',
        lastPositionMs: 2000,
        lastPageIndex: 1,
        chapterProgressPercent: 0.25,
      );

      await pumpEventQueue();

      expect(updates.length, 1);
      verify(() => repository.saveProgress(
            bookId: 'b1',
            chapterId: 'c1',
            lastPositionMs: 2000,
            lastPageIndex: 1,
            chapterProgressPercent: 0.25,
          )).called(1);
    });

    test('clamps chapter progress to [0, 1]', () async {
      when(() => repository.getBookProgressPercent('b1'))
          .thenAnswer((_) async => 0.0);

      final updates = <ReadingProgressUpdate>[];
      service.progressUpdates.listen(updates.add);

      await service.saveProgress(
        bookId: 'b1',
        chapterId: 'c1',
        lastPositionMs: 0,
        lastPageIndex: 0,
        chapterProgressPercent: 1.5,
      );

      await pumpEventQueue();

      expect(updates.first.chapterProgressPercent, 1.0);
    });
  });
}
