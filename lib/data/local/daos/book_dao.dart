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

  Future<void> deleteBook(String bookId) async {
    // Foreign keys are enabled, so deleting the book cascades to chapters,
    // bookmarks, reading progress, downloaded assets, and queue entries.
    await _db.delete(
      DbTables.localBooks,
      where: 'id = ?',
      whereArgs: [bookId],
    );
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

  Future<void> insertChapter(LocalChapter chapter) async {
    await _db.insert(
      DbTables.localChapters,
      chapter.toDb(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateBookCover(String bookId, String coverUrl) async {
    await _db.update(
      DbTables.localBooks,
      {'cover_url': coverUrl},
      where: 'id = ?',
      whereArgs: [bookId],
    );
  }

  Future<void> insertBook(LocalBook book) async {
    await _db.insert(
      DbTables.localBooks,
      book.toDb(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateBookMetadata(LocalBook book) async {
    await _db.update(
      DbTables.localBooks,
      {
        'title': book.title,
        'description': book.description,
        'cover_url': book.coverUrl,
        'book_type': book.type.dbValue,
        'version': book.version,
      },
      where: 'id = ?',
      whereArgs: [book.id],
    );
  }

  Future<void> updateBookInfo(LocalBook book) async {
    await _db.update(
      DbTables.localBooks,
      {
        'title': book.title,
        'description': book.description,
        'cover_url': book.coverUrl,
        'book_type': book.type.dbValue,
      },
      where: 'id = ?',
      whereArgs: [book.id],
    );
  }

  Future<void> updateBookVersion(String bookId, int version) async {
    await _db.update(
      DbTables.localBooks,
      {'version': version},
      where: 'id = ?',
      whereArgs: [bookId],
    );
  }

  Future<void> updateChapterMetadata(LocalChapter chapter) async {
    await _db.update(
      DbTables.localChapters,
      {
        'title': chapter.title,
        'description': chapter.description,
        'sort_order': chapter.sortOrder,
        'version': chapter.version,
      },
      where: 'id = ?',
      whereArgs: [chapter.id],
    );
  }

  Future<void> updateChapterInfo(LocalChapter chapter) async {
    await _db.update(
      DbTables.localChapters,
      {
        'title': chapter.title,
        'description': chapter.description,
        'sort_order': chapter.sortOrder,
      },
      where: 'id = ?',
      whereArgs: [chapter.id],
    );
  }

  Future<void> updateChapterContent(
    String chapterId, {
    String? contentText,
    String? contentSegmentsJson,
    bool? isDownloaded,
  }) async {
    final values = <String, Object?>{
      'content_text': contentText,
      'content_segments_json': contentSegmentsJson,
      if (isDownloaded != null) 'is_downloaded': isDownloaded ? 1 : 0,
    }..removeWhere((_, v) => v == null);
    await _db.update(
      DbTables.localChapters,
      values,
      where: 'id = ?',
      whereArgs: [chapterId],
    );
  }

  Future<void> markChapterDownloaded(String chapterId, bool downloaded) async {
    await _db.update(
      DbTables.localChapters,
      {'is_downloaded': downloaded ? 1 : 0},
      where: 'id = ?',
      whereArgs: [chapterId],
    );
  }

  Future<List<LocalBook>> getBooks() async {
    final rows = await _db.query(DbTables.localBooks, orderBy: 'id ASC');
    return rows.map((e) => LocalBook.fromDb(e)).toList();
  }

  Future<LocalBook?> getBook(String id) async {
    final rows = await _db.query(
      DbTables.localBooks,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return LocalBook.fromDb(rows.first);
  }

  Future<List<LocalChapter>> getChapters(String bookId) async {
    final rows = await _db.query(
      DbTables.localChapters,
      where: 'book_id = ?',
      whereArgs: [bookId],
      orderBy: 'sort_order ASC',
    );
    return rows.map((e) => LocalChapter.fromDb(e)).toList();
  }

  Future<LocalChapter?> getChapter(String id) async {
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
    required String bookId,
    required String chapterId,
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
    required String bookId,
    required String chapterId,
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
    required String bookId,
    required String chapterId,
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

  Future<void> insertDownloadedAsset({
    required String chapterId,
    required String assetType,
    required String filePath,
    int? sortOrder,
  }) async {
    await _db.insert(
      DbTables.downloadedAssets,
      {
        'chapter_id': chapterId,
        'asset_type': assetType,
        'sort_order': sortOrder,
        'file_path': filePath,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, Object?>>> getDownloadedAssets(
    String chapterId, {
    String? assetType,
  }) async {
    String? where;
    List<Object?>? whereArgs;
    if (assetType != null) {
      where = 'chapter_id = ? AND asset_type = ?';
      whereArgs = [chapterId, assetType];
    } else {
      where = 'chapter_id = ?';
      whereArgs = [chapterId];
    }
    return _db.query(
      DbTables.downloadedAssets,
      where: where,
      whereArgs: whereArgs,
      orderBy: 'sort_order ASC, id ASC',
    );
  }

  Future<void> deleteDownloadedAssets(
    String chapterId, {
    String? assetType,
  }) async {
    String? where;
    List<Object?>? whereArgs;
    if (assetType != null) {
      where = 'chapter_id = ? AND asset_type = ?';
      whereArgs = [chapterId, assetType];
    } else {
      where = 'chapter_id = ?';
      whereArgs = [chapterId];
    }
    await _db.delete(
      DbTables.downloadedAssets,
      where: where,
      whereArgs: whereArgs,
    );
  }

  Future<void> insertQueueItem({
    required String chapterId,
    required String bookId,
    required String status,
    double progress = 0.0,
    int retryCount = 0,
  }) async {
    await _db.insert(
      DbTables.downloadQueue,
      {
        'chapter_id': chapterId,
        'book_id': bookId,
        'status': status,
        'progress': progress,
        'retry_count': retryCount,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateQueueStatus({
    required String chapterId,
    required String status,
    double? progress,
    int? retryCount,
  }) async {
    final values = <String, Object?>{
      'status': status,
      'progress': progress,
      'retry_count': retryCount,
    }..removeWhere((_, v) => v == null);
    await _db.update(
      DbTables.downloadQueue,
      values,
      where: 'chapter_id = ?',
      whereArgs: [chapterId],
    );
  }

  Future<void> incrementRetryCount(String chapterId) async {
    await _db.rawUpdate(
      'UPDATE ${DbTables.downloadQueue} SET retry_count = retry_count + 1 WHERE chapter_id = ?',
      [chapterId],
    );
  }

  Future<List<Map<String, Object?>>> getQueue({String? status}) async {
    String? where;
    List<Object?>? whereArgs;
    if (status != null) {
      where = 'status = ?';
      whereArgs = [status];
    }
    return _db.query(
      DbTables.downloadQueue,
      where: where,
      whereArgs: whereArgs,
      orderBy: 'chapter_id ASC',
    );
  }

  Future<void> deleteQueueItem(String chapterId) async {
    await _db.delete(
      DbTables.downloadQueue,
      where: 'chapter_id = ?',
      whereArgs: [chapterId],
    );
  }
}
