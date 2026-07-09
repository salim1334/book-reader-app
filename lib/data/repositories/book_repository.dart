import 'dart:convert';

import 'package:book_store/data/local/daos/book_dao.dart';
import 'package:book_store/data/local/daos/settings_dao.dart';
import 'package:book_store/data/local/database_helper.dart';
import 'package:book_store/data/local/models/book_local_models.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// Repository providing access to the offline/template schema.
class BookRepository extends GetxService {
  static const _firstBookAssetPath = 'assets/data/first_book.json';
  static const _contentVersionKey = 'book_content_version';
  static const _currentContentVersion = '2';

  late final BookDao _dao;

  Future<BookRepository> init() async {
    final db = await DatabaseHelper.instance.database;
    _dao = BookDao(db);
    await _ensureSeeded();
    return this;
  }

  Future<void> _ensureSeeded() async {
    final settings = SettingsDao();
    final storedVersion = await settings.getString(_contentVersionKey);
    final hasContent = await _dao.hasContent();

    if (hasContent && storedVersion == _currentContentVersion) return;

    if (hasContent) {
      await _dao.clearBookContent();
    }

    // MVP: seed first bundled offline book from asset.
    // Expected asset shape is defined in docs; for now we support a minimal
    // JSON with `book` and `chapters`.
    final jsonStr = await rootBundle.loadString(_firstBookAssetPath);
    final data = jsonDecode(jsonStr) as Map<String, dynamic>;

    final bookRow = data['book'] as Map<String, dynamic>;
    final chaptersList = data['chapters'] as List<dynamic>;

    final book = LocalBook(
      id: bookRow['id'] as int,
      title: bookRow['title'] as String,
      description: bookRow['description'] as String?,
      coverUrl: bookRow['cover_url'] as String?,
      type: LocalBookTypeX.fromDb(bookRow['book_type'] as String),
      version: bookRow['version'] as int,
    );

    final chapters = chaptersList
        .map(
          (e) => LocalChapter(
            id: e['id'] as int,
            bookId: e['book_id'] as int,
            title: e['title'] as String,
            sortOrder: e['sort_order'] as int,
            contentText: e['content_text'] as String?,
            version: e['version'] as int,
          ),
        )
        .toList();

    await _dao.insertBooksAndChapters(book: book, chapters: chapters);
    await settings.setString(_contentVersionKey, _currentContentVersion);
  }

  Future<List<LocalBook>> getBooks() => _dao.getBooks();

  Future<LocalBook?> getBook(int id) => _dao.getBook(id);

  Future<List<LocalChapter>> getChapters(int bookId) =>
      _dao.getChapters(bookId);

  Future<LocalChapter?> getChapter(int chapterId) => _dao.getChapter(chapterId);

  Future<bool> hasReadingProgress() => _dao.hasReadingProgress();

  Future<Map<String, Object?>?> getLastReadingProgress() =>
      _dao.getLastReadingProgress();

  Future<void> saveProgress({
    required int bookId,
    required int chapterId,
    required int lastPositionMs,
    required int lastPageIndex,
  }) => _dao.saveReadingProgress(
    bookId: bookId,
    chapterId: chapterId,
    lastPositionMs: lastPositionMs,
    lastPageIndex: lastPageIndex,
  );

  Future<void> clearReadingProgress() => _dao.clearReadingProgress();

  Future<bool> isBookmarked({required int bookId, required int chapterId}) =>
      _dao.isBookmarked(bookId: bookId, chapterId: chapterId);

  Future<void> toggleBookmark({required int bookId, required int chapterId}) =>
      _dao.toggleBookmark(bookId: bookId, chapterId: chapterId);

  Future<int> countBooks() => _dao.countBooks();

  Future<int> countChapters() => _dao.countChapters();
}
