import 'package:book_store/data/local/models/book_local_models.dart';
import 'package:book_store/data/repositories/book_repository.dart';
import 'package:book_store/features/search/controllers/search_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../../helpers/mocks.dart';
import '../../helpers/test_setup.dart';

void main() {
  setupTestBinding();

  late MockBookRepository repository;

  setUp(() {
    resetGetX();
    repository = MockBookRepository();
    Get.put<BookRepository>(repository, permanent: true);
  });

  group('BookSearchController', () {
    test('query change triggers debounced search', () async {
      const books = [
        LocalBook(id: 'b1', title: 'Flutter', type: LocalBookType.text, version: 1),
      ];
      const chapters = [
        LocalChapter(id: 'c1', bookId: 'b1', title: 'Intro', sortOrder: 0, version: 1),
      ];

      when(() => repository.searchBooks('Flutter'))
          .thenAnswer((_) async => books);
      when(() => repository.searchChapters('Flutter'))
          .thenAnswer((_) async => chapters);

      final controller = BookSearchController();
      Get.put(controller);

      controller.onQueryChanged('Flutter');
      expect(controller.query.value, 'Flutter');

      await Future.delayed(const Duration(milliseconds: 400));

      expect(controller.books.length, 1);
      expect(controller.chapters.length, 1);
      expect(controller.isLoading.value, false);
    });

    test('empty query clears results', () async {
      when(() => repository.searchBooks(any())).thenAnswer((_) async => []);
      when(() => repository.searchChapters(any())).thenAnswer((_) async => []);

      final controller = BookSearchController();
      Get.put(controller);

      controller.onQueryChanged('test');
      await Future.delayed(const Duration(milliseconds: 400));
      controller.clearQuery();

      expect(controller.query.value, '');
      expect(controller.books.isEmpty, true);
      expect(controller.chapters.isEmpty, true);
    });
  });
}
