import 'package:book_store/data/local/models/book_local_models.dart';

class ContinueReading {
  final LocalBook book;
  final LocalChapter chapter;
  final int pageIndex;
  final int positionMs;

  const ContinueReading({
    required this.book,
    required this.chapter,
    this.pageIndex = 0,
    this.positionMs = 0,
  });
}
