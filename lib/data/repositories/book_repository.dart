import 'package:book_store/data/local/daos/book_dao.dart';
import 'package:book_store/data/local/database_helper.dart';
import 'package:book_store/data/local/models/book_local_models.dart';
import 'package:book_store/data/remote/download_manager.dart';
import 'package:get/get.dart';

/// Repository providing access to the offline/template schema.
class BookRepository extends GetxService {
  late final BookDao _dao;

  Future<BookRepository> init() async {
    final db = await DatabaseHelper.instance.database;
    _dao = BookDao(db);
    return this;
  }

  Future<List<LocalBook>> getBooks() => _dao.getBooks();

  Future<LocalBook?> getBook(String id) => _dao.getBook(id);

  Future<List<LocalChapter>> getChapters(String bookId) =>
      _dao.getChapters(bookId);

  Future<LocalChapter?> getChapter(String chapterId) => _dao.getChapter(chapterId);

  Future<bool> hasReadingProgress() => _dao.hasReadingProgress();

  Future<Map<String, Object?>?> getLastReadingProgress() =>
      _dao.getLastReadingProgress();

  Future<void> saveProgress({
    required String bookId,
    required String chapterId,
    required int lastPositionMs,
    required int lastPageIndex,
    double chapterProgressPercent = 0.0,
  }) => _dao.saveReadingProgress(
    bookId: bookId,
    chapterId: chapterId,
    lastPositionMs: lastPositionMs,
    lastPageIndex: lastPageIndex,
    chapterProgressPercent: chapterProgressPercent,
  );

  Future<Map<String, Object?>?> getReadingProgress({
    required String bookId,
    required String chapterId,
  }) => _dao.getReadingProgress(bookId: bookId, chapterId: chapterId);

  Future<double> getBookProgressPercent(String bookId) =>
      _dao.getBookProgressPercent(bookId);

  Future<Map<String, double>> getChaptersProgressPercent(String bookId) =>
      _dao.getChaptersProgressPercent(bookId);

  Future<void> clearReadingProgress() => _dao.clearReadingProgress();

  Future<bool> isBookmarked({required String bookId, required String chapterId}) =>
      _dao.isBookmarked(bookId: bookId, chapterId: chapterId);

  Future<void> toggleBookmark({required String bookId, required String chapterId}) =>
      _dao.toggleBookmark(bookId: bookId, chapterId: chapterId);

  Future<int> countBooks() => _dao.countBooks();

  Future<int> countChapters() => _dao.countChapters();

  Future<void> clearContent() async {
    await _dao.clearBookContent();
    await Get.find<DownloadManager>().clearDownloads();
  }

  Future<void> deleteBook(String bookId) async {
    await _dao.deleteBook(bookId);
    await Get.find<DownloadManager>().deleteBookAssets(bookId);
  }

  Future<List<Map<String, Object?>>> getDownloadQueue({String? status}) =>
      _dao.getQueue(status: status);

  Future<void> recordDownloadedAsset({
    required String chapterId,
    required String assetType,
    required String filePath,
    int? sortOrder,
  }) => _dao.insertDownloadedAsset(
        chapterId: chapterId,
        assetType: assetType,
        filePath: filePath,
        sortOrder: sortOrder,
      );

  Future<List<Map<String, Object?>>> getChapterAssets(
    String chapterId, {
    String? assetType,
  }) => _dao.getDownloadedAssets(chapterId, assetType: assetType);

  Future<bool> isBookFavorite(String bookId) => _dao.isBookFavorite(bookId);

  Future<void> setBookFavorite(String bookId, bool favorite) =>
      _dao.setBookFavorite(bookId, favorite);

  Future<bool> isChapterFavorite(String chapterId) =>
      _dao.isChapterFavorite(chapterId);

  Future<void> setChapterFavorite(String chapterId, bool favorite) =>
      _dao.setChapterFavorite(chapterId, favorite);

  Future<List<LocalBook>> getFavoriteBooks() => _dao.getFavoriteBooks();

  Future<List<LocalChapter>> getFavoriteChapters({String? bookId}) =>
      _dao.getFavoriteChapters(bookId: bookId);

  Future<List<LocalBook>> searchBooks(String query) => _dao.searchBooks(query);

  Future<List<LocalChapter>> searchChapters(String query) =>
      _dao.searchChapters(query);

  Future<bool> isPageFavorite({
    required String bookId,
    required String chapterId,
    required int pageIndex,
  }) =>
      _dao.isPageFavorite(
        bookId: bookId,
        chapterId: chapterId,
        pageIndex: pageIndex,
      );

  Future<void> setPageFavorite({
    required String bookId,
    required String chapterId,
    required int pageIndex,
    required bool favorite,
  }) =>
      _dao.setPageFavorite(
        bookId: bookId,
        chapterId: chapterId,
        pageIndex: pageIndex,
        favorite: favorite,
      );

  Future<List<Map<String, Object?>>> getFavoritePages({String? bookId}) =>
      _dao.getFavoritePages(bookId: bookId);
}
