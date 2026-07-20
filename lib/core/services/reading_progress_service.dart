import 'dart:async';

import 'package:book_store/data/repositories/book_repository.dart';
import 'package:get/get.dart';

/// Emitted whenever reading progress is saved so that any screen can react
/// instantly without requiring a manual refresh.
class ReadingProgressUpdate {
  final String bookId;
  final String chapterId;
  final int lastPageIndex;
  final int lastPositionMs;
  final double chapterProgressPercent;
  final double bookProgressPercent;

  ReadingProgressUpdate({
    required this.bookId,
    required this.chapterId,
    required this.lastPageIndex,
    required this.lastPositionMs,
    required this.chapterProgressPercent,
    required this.bookProgressPercent,
  });
}

/// Central service for persisting and broadcasting reading progress updates.
///
/// Readers call [saveProgress] instead of going directly to [BookRepository]
/// so that observers (Home, Book Details, etc.) receive the new progress
/// immediately through [progressUpdates].
class _ProgressKey {
  final int lastPageIndex;
  final double chapterProgressPercent;

  _ProgressKey(this.lastPageIndex, this.chapterProgressPercent);

  bool isSameAs(int pageIndex, double progress) =>
      lastPageIndex == pageIndex && chapterProgressPercent == progress;
}

class ReadingProgressService extends GetxService {
  final BookRepository _repository = Get.find<BookRepository>();

  final _progressUpdates = StreamController<ReadingProgressUpdate>.broadcast();
  Stream<ReadingProgressUpdate> get progressUpdates => _progressUpdates.stream;

  /// Used to skip redundant broadcasts for position-only updates (e.g., audio
  /// position ticking) while still persisting them to the DB.
  final _lastEmitted = <String, _ProgressKey>{};

  Future<void> saveProgress({
    required String bookId,
    required String chapterId,
    required int lastPositionMs,
    required int lastPageIndex,
    double chapterProgressPercent = 0.0,
  }) async {
    final clampedProgress = chapterProgressPercent.clamp(0.0, 1.0).toDouble();

    // Always persist so resume position is up to date.
    await _repository.saveProgress(
      bookId: bookId,
      chapterId: chapterId,
      lastPositionMs: lastPositionMs,
      lastPageIndex: lastPageIndex,
      chapterProgressPercent: clampedProgress,
    );

    final lastKey = _lastEmitted[chapterId];
    if (lastKey != null && lastKey.isSameAs(lastPageIndex, clampedProgress)) {
      // No visual progress change, avoid extra queries and UI rebuilds.
      return;
    }

    final bookProgressPercent = await _repository.getBookProgressPercent(bookId);

    _lastEmitted[chapterId] = _ProgressKey(lastPageIndex, clampedProgress);
    _progressUpdates.add(
      ReadingProgressUpdate(
        bookId: bookId,
        chapterId: chapterId,
        lastPageIndex: lastPageIndex,
        lastPositionMs: lastPositionMs,
        chapterProgressPercent: clampedProgress,
        bookProgressPercent: bookProgressPercent,
      ),
    );
  }

  @override
  void onClose() {
    _progressUpdates.close();
    super.onClose();
  }
}
