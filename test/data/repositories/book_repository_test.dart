import 'package:book_store/data/local/models/book_local_models.dart';
import 'package:book_store/data/remote/download_manager.dart';
import 'package:book_store/data/repositories/book_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mocks.dart';
import '../../helpers/test_setup.dart';

void main() {
  setupTestBinding();

  late MockBookDao dao;
  late BookRepository repository;
  late FakeDownloadManager downloadManager;

  setUp(() async {
    resetGetX();
    dao = MockBookDao();
    downloadManager = FakeDownloadManager();
    Get.put<DownloadManager>(downloadManager, permanent: true);
    repository = await BookRepository().init(dao: dao);
  });

  group('BookRepository delegates to DAO', () {
    test('getBooks returns dao result', () async {
      const books = [LocalBook(id: 'b1', title: 'Book', type: LocalBookType.text, version: 1)];
      when(() => dao.getBooks()).thenAnswer((_) async => books);

      final result = await repository.getBooks();
      expect(result, books);
      verify(() => dao.getBooks()).called(1);
    });

    test('getBook returns dao result', () async {
      const book = LocalBook(id: 'b1', title: 'Book', type: LocalBookType.text, version: 1);
      when(() => dao.getBook('b1')).thenAnswer((_) async => book);

      final result = await repository.getBook('b1');
      expect(result, book);
    });

    test('getChapters delegates', () async {
      const chapters = [LocalChapter(id: 'c1', bookId: 'b1', title: 'Ch1', sortOrder: 0, version: 1)];
      when(() => dao.getChapters('b1')).thenAnswer((_) async => chapters);

      final result = await repository.getChapters('b1');
      expect(result, chapters);
    });

    test('saveProgress delegates', () async {
      when(
        () => dao.saveReadingProgress(
          bookId: any(named: 'bookId'),
          chapterId: any(named: 'chapterId'),
          lastPositionMs: any(named: 'lastPositionMs'),
          lastPageIndex: any(named: 'lastPageIndex'),
          chapterProgressPercent: any(named: 'chapterProgressPercent'),
        ),
      ).thenAnswer((_) async {});

      await repository.saveProgress(
        bookId: 'b1',
        chapterId: 'c1',
        lastPositionMs: 1000,
        lastPageIndex: 2,
        chapterProgressPercent: 0.5,
      );

      verify(
        () => dao.saveReadingProgress(
          bookId: 'b1',
          chapterId: 'c1',
          lastPositionMs: 1000,
          lastPageIndex: 2,
          chapterProgressPercent: 0.5,
        ),
      ).called(1);
    });

    test('favorite changes bump favoriteVersion', () async {
      when(() => dao.setBookFavorite(any(), any())).thenAnswer((_) async {});
      when(() => dao.setChapterFavorite(any(), any())).thenAnswer((_) async {});
      when(
        () => dao.setPageFavorite(
          bookId: any(named: 'bookId'),
          chapterId: any(named: 'chapterId'),
          pageIndex: any(named: 'pageIndex'),
          favorite: any(named: 'favorite'),
        ),
      ).thenAnswer((_) async {});

      final before = repository.favoriteVersion.value;

      await repository.setBookFavorite('b1', true);
      expect(repository.favoriteVersion.value, before + 1);

      await repository.setChapterFavorite('c1', true);
      expect(repository.favoriteVersion.value, before + 2);

      await repository.setPageFavorite(bookId: 'b1', chapterId: 'c1', pageIndex: 0, favorite: true);
      expect(repository.favoriteVersion.value, before + 3);
    });

    test('clearContent delegates to dao and download manager', () async {
      when(() => dao.clearBookContent()).thenAnswer((_) async {});

      await repository.clearContent();

      verify(() => dao.clearBookContent()).called(1);
    });

    test('deleteBook delegates to dao and download manager', () async {
      when(() => dao.deleteBook('b1')).thenAnswer((_) async {});

      await repository.deleteBook('b1');

      verify(() => dao.deleteBook('b1')).called(1);
    });
  });
}
