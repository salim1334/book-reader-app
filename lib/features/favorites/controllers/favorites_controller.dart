import 'package:book_store/data/local/models/book_local_models.dart';
import 'package:book_store/data/repositories/book_repository.dart';
import 'package:book_store/features/book_details/presentation/arguments/book_details_args.dart';
import 'package:book_store/features/chapter_reader/presentation/arguments/chapter_reader_args.dart';
import 'package:book_store/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FavoritesController extends GetxController {
  final BookRepository _repository = Get.find<BookRepository>();

  final isLoading = false.obs;
  final favoriteBooks = <LocalBook>[].obs;
  final favoriteChapters = <LocalChapter>[].obs;
  final favoritePages = <Map<String, Object?>>[].obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    ever(_repository.favoriteVersion, (_) => load());

    await load();
  }

  Future<void> load() async {
    try {
      isLoading.value = true;
      final books = await _repository.getFavoriteBooks();
      final chapters = await _repository.getFavoriteChapters();
      final pages = await _repository.getFavoritePages();
      favoriteBooks.value = books;
      favoriteChapters.value = chapters;
      favoritePages.value = pages;
    } catch (e) {
      debugPrint('FavoritesController.load error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void openBook(LocalBook book) {
    Get.toNamed(Routes.bookDetails, arguments: BookDetailsArgs(book: book));
  }

  Future<void> openChapter(LocalChapter chapter) async {
    final book = await _repository.getBook(chapter.bookId);
    if (book == null) {
      debugPrint('Book not found for chapter ${chapter.id}');
      return;
    }
    if (!chapter.isDownloaded) {
      openBook(book);
      return;
    }
    Get.toNamed(
      Routes.chapterReader,
      arguments: ChapterReaderArgs(book: book, chapter: chapter),
    );
  }

  Future<void> openPage(Map<String, Object?> page) async {
    final bookId = page['book_id']?.toString();
    final chapterId = page['chapter_id']?.toString();
    final pageIndex = (page['page_index'] as num?)?.toInt() ?? 0;
    if (bookId == null || chapterId == null) return;

    final book = await _repository.getBook(bookId);
    final chapter = await _repository.getChapter(chapterId);
    if (book == null || chapter == null) return;

    Get.toNamed(
      Routes.chapterReader,
      arguments: ChapterReaderArgs(
        book: book,
        chapter: chapter,
        initialPageIndex: pageIndex,
      ),
    );
  }

  Future<void> removePageFavorite(Map<String, Object?> page) async {
    final bookId = page['book_id']?.toString();
    final chapterId = page['chapter_id']?.toString();
    final pageIndex = (page['page_index'] as num?)?.toInt() ?? 0;
    if (bookId == null || chapterId == null) return;

    await _repository.setPageFavorite(
      bookId: bookId,
      chapterId: chapterId,
      pageIndex: pageIndex,
      favorite: false,
    );
    await load();
  }

  // remove chapters favorite
  Future<void> removeChapterFavorite(LocalChapter chapter) async {
    await _repository.setChapterFavorite(chapter.id, false);
    await load();
  }

  // remove books favorite
  Future<void> removeBooksFavorite(LocalBook book) async {
    await _repository.setBookFavorite(book.id, false);
    await load();
  }
}
