import 'package:book_store/data/local/models/book_local_models.dart';
import 'package:book_store/data/local/tables.dart';
import 'package:sqflite/sqflite.dart';

/// Offline local DAO for the template schema.
class BookDao {
  BookDao(this._db);

  final Database _db;

  Future<bool> hasContent() async {
    final result = await _db.rawQuery(
      'SELECT COUNT(*) as c FROM ${DbTables.localBooks}',
    );
    return (result.first['c'] as int) > 0;
  }

  Future<void> clearBookContent() async {
    // Keep settings/user_settings intact; remove local book metadata/state.
    await _db.delete(DbTables.bookmarks);
    await _db.delete(DbTables.readingProgress);
    await _db.delete(DbTables.downloadQueue);
    await _db.delete(DbTables.downloadedAssets);
    await _db.delete(DbTables.localChapters);
    await _db.delete(DbTables.localBooks);
  }

  Future<void> insertBooksAndChapters({
    required LocalBook book,
    required List<LocalChapter> chapters,
  }) async {
    final batch = _db.batch();
    batch.insert(
      DbTables.localBooks,
      book.toDb(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    for (final ch in chapters) {
      batch.insert(
        DbTables.localChapters,
        ch.toDb(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<LocalBook>> getBooks() async {
    final rows = await _db.query(DbTables.localBooks, orderBy: 'id ASC');
    return rows.map((e) => LocalBook.fromDb(e)).toList();
  }

  Future<LocalBook?> getBook(int id) async {
    final rows = await _db.query(
      DbTables.localBooks,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return LocalBook.fromDb(rows.first);
  }

  Future<List<LocalChapter>> getChapters(int bookId) async {
    final rows = await _db.query(
      DbTables.localChapters,
      where: 'book_id = ?',
      whereArgs: [bookId],
      orderBy: 'sort_order ASC',
    );
    return rows.map((e) => LocalChapter.fromDb(e)).toList();
  }

  Future<LocalChapter?> getChapter(int id) async {
    final rows = await _db.query(
      DbTables.localChapters,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return LocalChapter.fromDb(rows.first);
  }

  Future<void> saveReadingProgress({
    required int bookId,
    required int chapterId,
    required int lastPositionMs,
    required int lastPageIndex,
  }) async {
    // reading_progress uses book_id as PK. Upsert by replace.
    await _db.transaction((txn) async {
      await txn.insert(DbTables.readingProgress, {
        'book_id': bookId,
        'chapter_id': chapterId,
        'last_position_ms': lastPositionMs,
        'last_page_index': lastPageIndex,
        'updated_at': DateTime.now().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }

  Future<bool> hasReadingProgress() async {
    final rows = await _db.query(DbTables.readingProgress, limit: 1);
    return rows.isNotEmpty;
  }

  Future<Map<String, Object?>?> getLastReadingProgress() async {
    final rows = await _db.query(
      DbTables.readingProgress,
      orderBy: 'updated_at DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first;
  }

  Future<void> clearReadingProgress() async {
    await _db.delete(DbTables.readingProgress);
  }

  Future<bool> isBookmarked({
    required int bookId,
    required int chapterId,
  }) async {
    final rows = await _db.query(
      DbTables.bookmarks,
      where: 'book_id = ? AND chapter_id = ?',
      whereArgs: [bookId, chapterId],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<void> toggleBookmark({
    required int bookId,
    required int chapterId,
  }) async {
    final exists = await isBookmarked(bookId: bookId, chapterId: chapterId);
    if (exists) {
      await _db.delete(
        DbTables.bookmarks,
        where: 'book_id = ? AND chapter_id = ?',
        whereArgs: [bookId, chapterId],
      );
    } else {
      await _db.insert(DbTables.bookmarks, {
        'book_id': bookId,
        'chapter_id': chapterId,
        'created_at': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<int> countBooks() async {
    final r = await _db.rawQuery(
      'SELECT COUNT(*) as c FROM ${DbTables.localBooks}',
    );
    return r.first['c'] as int;
  }

  Future<int> countChapters() async {
    final r = await _db.rawQuery(
      'SELECT COUNT(*) as c FROM ${DbTables.localChapters}',
    );
    return r.first['c'] as int;
  }
}
