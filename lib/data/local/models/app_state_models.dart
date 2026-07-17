class LocalReadingProgress {
  const LocalReadingProgress({
    required this.bookId,
    required this.chapterId,
    this.lastPositionMs = 0,
    this.lastPageIndex = 0,
    this.chapterProgressPercent = 0.0,
    required this.updatedAtIso,
  });

  final String bookId;
  final String chapterId;
  final int lastPositionMs;
  final int lastPageIndex;
  final double chapterProgressPercent;
  final String updatedAtIso;

  Map<String, Object?> toDb() => {
    'book_id': bookId,
    'chapter_id': chapterId,
    'last_position_ms': lastPositionMs,
    'last_page_index': lastPageIndex,
    'chapter_progress_percent': chapterProgressPercent,
    'updated_at': updatedAtIso,
  };

  static LocalReadingProgress fromDb(Map<String, Object?> row) {
    return LocalReadingProgress(
      bookId: row['book_id']?.toString() ?? '',
      chapterId: row['chapter_id']?.toString() ?? '',
      lastPositionMs: (row['last_position_ms'] as num?)?.toInt() ?? 0,
      lastPageIndex: (row['last_page_index'] as num?)?.toInt() ?? 0,
      chapterProgressPercent: (row['chapter_progress_percent'] as num?)?.toDouble() ?? 0.0,
      updatedAtIso: row['updated_at']?.toString() ?? '',
    );
  }
}
