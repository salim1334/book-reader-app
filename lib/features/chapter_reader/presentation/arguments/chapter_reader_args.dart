import 'package:book_store/data/local/models/book_local_models.dart';

class ChapterReaderArgs {
  final LocalBook book;
  final LocalChapter chapter;
  final int initialPageIndex;
  final int initialPositionMs;

  const ChapterReaderArgs({
    required this.book,
    required this.chapter,
    this.initialPageIndex = 0,
    this.initialPositionMs = 0,
  });
}
