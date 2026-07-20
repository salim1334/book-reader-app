import 'dart:async';

import 'package:book_store/data/local/models/book_local_models.dart';
import 'package:book_store/data/repositories/book_repository.dart';
import 'package:book_store/features/book_details/presentation/arguments/book_details_args.dart';
import 'package:book_store/features/chapter_reader/presentation/arguments/chapter_reader_args.dart';
import 'package:book_store/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BookSearchController extends GetxController {
  final BookRepository _repository = Get.find<BookRepository>();

  final query = ''.obs;
  final isLoading = false.obs;
  final books = <LocalBook>[].obs;
  final chapters = <LocalChapter>[].obs;

  final TextEditingController textController = TextEditingController();
  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    ever(query, (_) => _search());
  }

  @override
  void onClose() {
    _debounce?.cancel();
    textController.dispose();
    super.onClose();
  }

  void onQueryChanged(String value) {
    query.value = value.trim();
  }

  void clearQuery() {
    query.value = '';
    textController.clear();
  }

  Future<void> _search() async {
    _debounce?.cancel();
    final trimmed = query.value;
    if (trimmed.isEmpty) {
      books.clear();
      chapters.clear();
      isLoading.value = false;
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 300), () async {
      isLoading.value = true;
      try {
        final results = await Future.wait([
          _repository.searchBooks(trimmed),
          _repository.searchChapters(trimmed),
        ]);
        books.value = results[0] as List<LocalBook>;
        chapters.value = results[1] as List<LocalChapter>;
      } catch (e) {
        debugPrint('SearchController._search error: $e');
      } finally {
        isLoading.value = false;
      }
    });
  }

  void openBook(LocalBook book) {
    Get.toNamed(
      Routes.bookDetails,
      arguments: BookDetailsArgs(book: book),
    );
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
      arguments: ChapterReaderArgs(
        book: book,
        chapter: chapter,
      ),
    );
  }
}
