import 'package:book_store/data/local/models/book_local_models.dart';
import 'package:book_store/data/repositories/book_repository.dart';
import 'package:book_store/features/favorites/controllers/favorites_controller.dart';
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

  group('FavoritesController', () {
    test('load populates all favorite lists', () async {
      const books = [
        LocalBook(id: 'b1', title: 'Book 1', type: LocalBookType.text, version: 1),
      ];
      const chapters = [
        LocalChapter(id: 'c1', bookId: 'b1', title: 'Ch1', sortOrder: 0, version: 1),
      ];
      const pages = [
        <String, Object?>{
          'book_id': 'b1',
          'chapter_id': 'c1',
          'page_index': 0,
        }
      ];

      when(() => repository.favoriteVersion).thenReturn(0.obs);
      when(() => repository.getFavoriteBooks()).thenAnswer((_) async => books);
      when(() => repository.getFavoriteChapters())
          .thenAnswer((_) async => chapters);
      when(() => repository.getFavoritePages())
          .thenAnswer((_) async => pages);

      final controller = FavoritesController();
      Get.put(controller);
      await controller.load();

      expect(controller.favoriteBooks.length, 1);
      expect(controller.favoriteChapters.length, 1);
      expect(controller.favoritePages.length, 1);
      expect(controller.isLoading.value, false);
    });

    test('removeBookFavorite calls repository and reloads', () async {
      const book = LocalBook(
        id: 'b1',
        title: 'Book',
        type: LocalBookType.text,
        version: 1,
      );

      when(() => repository.favoriteVersion).thenReturn(0.obs);
      when(() => repository.getFavoriteBooks()).thenAnswer((_) async => []);
      when(() => repository.getFavoriteChapters())
          .thenAnswer((_) async => []);
      when(() => repository.getFavoritePages())
          .thenAnswer((_) async => []);
      when(() => repository.setBookFavorite('b1', false))
          .thenAnswer((_) async {});

      final controller = FavoritesController();
      Get.put(controller);

      await controller.removeBooksFavorite(book);

      verify(() => repository.setBookFavorite('b1', false)).called(1);
    });
  });
}
