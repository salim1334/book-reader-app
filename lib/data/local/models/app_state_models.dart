class LocalReadingProgress {
  const LocalReadingProgress({
    required this.bookId,
    required this.chapterId,
    this.lastPositionMs = 0,
    this.lastPageIndex = 0,
    required this.updatedAtIso,
  });

  final int bookId;
  final int chapterId;
  final int lastPositionMs;
  final int lastPageIndex;
  final String updatedAtIso;

  Map<String, Object?> toDb() => {
    'book_id': bookId,
    'chapter_id': chapterId,
    'last_position_ms': lastPositionMs,
    'last_page_index': lastPageIndex,
    'updated_at': updatedAtIso,
  };
}
