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
    // Keep settings/user_settings and book/chapter metadata intact;
    // remove downloaded content state so the user can re-download later.
    await _db.delete(DbTables.bookmarks);
    await _db.delete(DbTables.readingProgress);
    await _db.delete(DbTables.downloadQueue);
    await _db.delete(DbTables.downloadedAssets);
    await _db.delete(DbTables.syncVersions);
    await _db.update(
      DbTables.localChapters,
      {
        'is_downloaded': 0,
        'content_text': null,
        'content_segments_json': null,
      },
    );
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
    final existingBook = await _db.query(
      DbTables.localBooks,
      columns: ['is_favorite'],
      where: 'id = ?',
      whereArgs: [book.id],
      limit: 1,
    );
    final isBookFavorite = existingBook.isEmpty
        ? book.isFavorite
        : (existingBook.first['is_favorite'] as num?)?.toInt() == 1;
    final bookValues = Map<String, Object?>.from(book.toDb());
    bookValues['is_favorite'] = isBookFavorite ? 1 : 0;

    final batch = _db.batch();
    batch.insert(
      DbTables.localBooks,
      bookValues,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    for (final ch in chapters) {
      final existingChapter = await _db.query(
        DbTables.localChapters,
        columns: ['is_favorite', 'is_downloaded'],
        where: 'id = ?',
        whereArgs: [ch.id],
        limit: 1,
      );
      final isChapterFavorite = existingChapter.isEmpty
          ? ch.isFavorite
          : (existingChapter.first['is_favorite'] as num?)?.toInt() == 1;
      final isChapterDownloaded = existingChapter.isEmpty
          ? ch.isDownloaded
          : (existingChapter.first['is_downloaded'] as num?)?.toInt() == 1;
      final chapterValues = Map<String, Object?>.from(ch.toDb());
      chapterValues['is_favorite'] = isChapterFavorite ? 1 : 0;
      chapterValues['is_downloaded'] = isChapterDownloaded ? 1 : 0;
      batch.insert(
        DbTables.localChapters,
        chapterValues,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<void> insertChapter(LocalChapter chapter) async {
    final existing = await _db.query(
      DbTables.localChapters,
      columns: ['is_favorite', 'is_downloaded'],
      where: 'id = ?',
      whereArgs: [chapter.id],
      limit: 1,
    );
    final isFavorite = existing.isEmpty
        ? chapter.isFavorite
        : (existing.first['is_favorite'] as num?)?.toInt() == 1;
    final isDownloaded = existing.isEmpty
        ? chapter.isDownloaded
        : (existing.first['is_downloaded'] as num?)?.toInt() == 1;
    final values = Map<String, Object?>.from(chapter.toDb());
    values['is_favorite'] = isFavorite ? 1 : 0;
    values['is_downloaded'] = isDownloaded ? 1 : 0;
    await _db.insert(
      DbTables.localChapters,
      values,
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
    final existing = await _db.query(
      DbTables.localBooks,
      columns: ['is_favorite'],
      where: 'id = ?',
      whereArgs: [book.id],
      limit: 1,
    );
    final isFavorite = existing.isEmpty
        ? book.isFavorite
        : (existing.first['is_favorite'] as num?)?.toInt() == 1;
    final values = Map<String, Object?>.from(book.toDb());
    values['is_favorite'] = isFavorite ? 1 : 0;
    await _db.insert(
      DbTables.localBooks,
      values,
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
        'swipe_direction': book.swipeDirection.dbValue,
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
        'swipe_direction': book.swipeDirection.dbValue,
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

  Future<bool> isBookFavorite(String bookId) async {
    final rows = await _db.query(
      DbTables.localBooks,
      columns: ['is_favorite'],
      where: 'id = ?',
      whereArgs: [bookId],
      limit: 1,
    );
    return (rows.isEmpty ? null : rows.first['is_favorite'] as num?)?.toInt() == 1;
  }

  Future<void> setBookFavorite(String bookId, bool favorite) async {
    await _db.update(
      DbTables.localBooks,
      {'is_favorite': favorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [bookId],
    );
  }

  Future<bool> isChapterFavorite(String chapterId) async {
    final rows = await _db.query(
      DbTables.localChapters,
      columns: ['is_favorite'],
      where: 'id = ?',
      whereArgs: [chapterId],
      limit: 1,
    );
    return (rows.isEmpty ? null : rows.first['is_favorite'] as num?)?.toInt() == 1;
  }

  Future<void> setChapterFavorite(String chapterId, bool favorite) async {
    await _db.update(
      DbTables.localChapters,
      {'is_favorite': favorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [chapterId],
    );
  }

  Future<List<LocalBook>> getFavoriteBooks() async {
    final rows = await _db.query(
      DbTables.localBooks,
      where: 'is_favorite = 1',
      orderBy: 'id ASC',
    );
    return rows.map((e) => LocalBook.fromDb(e)).toList();
  }

  Future<List<LocalChapter>> getFavoriteChapters({String? bookId}) async {
    String? where;
    List<Object?>? whereArgs;
    if (bookId != null) {
      where = 'is_favorite = 1 AND book_id = ?';
      whereArgs = [bookId];
    } else {
      where = 'is_favorite = 1';
    }
    final rows = await _db.query(
      DbTables.localChapters,
      where: where,
      whereArgs: whereArgs,
      orderBy: 'book_id ASC, sort_order ASC',
    );
    return rows.map((e) => LocalChapter.fromDb(e)).toList();
  }

  Future<bool> isPageFavorite({
    required String bookId,
    required String chapterId,
    required int pageIndex,
  }) async {
    final rows = await _db.query(
      DbTables.favoritePages,
      where: 'book_id = ? AND chapter_id = ? AND page_index = ?',
      whereArgs: [bookId, chapterId, pageIndex],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<void> setPageFavorite({
    required String bookId,
    required String chapterId,
    required int pageIndex,
    required bool favorite,
  }) async {
    if (!favorite) {
      await _db.delete(
        DbTables.favoritePages,
        where: 'book_id = ? AND chapter_id = ? AND page_index = ?',
        whereArgs: [bookId, chapterId, pageIndex],
      );
      return;
    }
    await _db.insert(
      DbTables.favoritePages,
      {
        'book_id': bookId,
        'chapter_id': chapterId,
        'page_index': pageIndex,
        'created_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<List<Map<String, Object?>>> getFavoritePages({String? bookId}) async {
    final where = bookId == null ? '' : 'WHERE fp.book_id = ?';
    final args = bookId == null ? <Object?>[] : <Object?>[bookId];
    return _db.rawQuery('''
      SELECT fp.*, b.title as book_title, c.title as chapter_title
      FROM ${DbTables.favoritePages} fp
      JOIN ${DbTables.localBooks} b ON fp.book_id = b.id
      JOIN ${DbTables.localChapters} c ON fp.chapter_id = c.id
      $where
      ORDER BY fp.created_at DESC
    ''', args);
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

  Future<List<LocalBook>> searchBooks(String query) async {
    final pattern = '%$query%';
    final rows = await _db.query(
      DbTables.localBooks,
      where: 'title LIKE ?',
      whereArgs: [pattern],
      orderBy: 'id ASC',
    );
    return rows.map((e) => LocalBook.fromDb(e)).toList();
  }

  Future<List<LocalChapter>> searchChapters(String query) async {
    final pattern = '%$query%';
    final rows = await _db.query(
      DbTables.localChapters,
      where: 'title LIKE ?',
      whereArgs: [pattern],
      orderBy: 'book_id ASC, sort_order ASC',
    );
    return rows.map((e) => LocalChapter.fromDb(e)).toList();
  }

  Future<void> saveReadingProgress({
    required String bookId,
    required String chapterId,
    required int lastPositionMs,
    required int lastPageIndex,
    double chapterProgressPercent = 0.0,
  }) async {
    await _db.transaction((txn) async {
      final existing = await txn.query(
        DbTables.readingProgress,
        where: 'book_id = ? AND chapter_id = ?',
        whereArgs: [bookId, chapterId],
        limit: 1,
      );

      final current = existing.isEmpty ? null : existing.first;
      final storedPageIndex = (current?['last_page_index'] as num?)?.toInt() ?? 0;
      final storedPositionMs = (current?['last_position_ms'] as num?)?.toInt() ?? 0;
      final storedProgress = (current?['chapter_progress_percent'] as num?)?.toDouble() ?? 0.0;

      await txn.insert(DbTables.readingProgress, {
        'book_id': bookId,
        'chapter_id': chapterId,
        'last_position_ms': lastPositionMs > storedPositionMs ? lastPositionMs : storedPositionMs,
        'last_page_index': lastPageIndex > storedPageIndex ? lastPageIndex : storedPageIndex,
        'chapter_progress_percent': chapterProgressPercent.clamp(0.0, 1.0) > storedProgress
            ? chapterProgressPercent.clamp(0.0, 1.0)
            : storedProgress,
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

  Future<Map<String, Object?>?> getReadingProgress({
    required String bookId,
    required String chapterId,
  }) async {
    final rows = await _db.query(
      DbTables.readingProgress,
      where: 'book_id = ? AND chapter_id = ?',
      whereArgs: [bookId, chapterId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first;
  }

  Future<double> getBookProgressPercent(String bookId) async {
    final rows = await _db.rawQuery('''
      SELECT
        COALESCE(SUM(r.chapter_progress_percent), 0.0) / NULLIF(COUNT(c.id), 0) as book_progress
      FROM ${DbTables.localChapters} c
      LEFT JOIN ${DbTables.readingProgress} r ON c.id = r.chapter_id
      WHERE c.book_id = ?
    ''', [bookId]);
    return (rows.first['book_progress'] as num?)?.toDouble() ?? 0.0;
  }

  Future<Map<String, double>> getChaptersProgressPercent(String bookId) async {
    final rows = await _db.query(
      DbTables.readingProgress,
      columns: ['chapter_id', 'chapter_progress_percent'],
      where: 'book_id = ?',
      whereArgs: [bookId],
    );
    return {
      for (final row in rows)
        row['chapter_id']!.toString(): (row['chapter_progress_percent'] as num?)?.toDouble() ?? 0.0,
    };
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
    double? audioStartTime,
    double? audioEndTime,
  }) async {
    await _db.insert(
      DbTables.downloadedAssets,
      {
        'chapter_id': chapterId,
        'asset_type': assetType,
        'sort_order': sortOrder,
        'file_path': filePath,
        'audio_start_time': audioStartTime,
        'audio_end_time': audioEndTime,
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
