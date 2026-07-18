import 'package:book_store/core/services/audio_player_service.dart';
import 'package:book_store/data/local/models/book_local_models.dart';
import 'package:book_store/data/repositories/book_repository.dart';
import 'package:book_store/features/chapter_reader/presentation/arguments/chapter_reader_args.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChapterReaderController extends GetxController {
  final BookRepository _repository = Get.find<BookRepository>();
  final AudioPlayerService _audio = Get.find<AudioPlayerService>();

  late final LocalBook book;
  late final LocalChapter chapter;
  late final int initialPageIndex;
  late final int initialPositionMs;

  final lastPageIndex = 0.obs;
  final lastPositionMs = 0.obs;
  final chapterProgressPercent = 0.0.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    final args = Get.arguments as ChapterReaderArgs?;
    if (args == null) {
      throw Exception('ChapterReaderArgs is required');
    }
    book = args.book;
    chapter = args.chapter;
    initialPageIndex = args.initialPageIndex;
    initialPositionMs = args.initialPositionMs;

    lastPageIndex.value = initialPageIndex;
    lastPositionMs.value = initialPositionMs;
    _audio.isReaderActive.value = true;

    await _saveProgress(
      pageIndex: initialPageIndex,
      positionMs: initialPositionMs,
      chapterProgressPercent: 0.0,
    );
  }

  Future<void> updatePage(int pageIndex) async {
    lastPageIndex.value = pageIndex;
    await _saveProgress(pageIndex: pageIndex);
  }

  Future<void> updatePosition(int positionMs) async {
    lastPositionMs.value = positionMs;
    await _saveProgress(positionMs: positionMs);
  }

  Future<void> updateProgress(double progress) async {
    chapterProgressPercent.value = progress;
    await _saveProgress(chapterProgressPercent: progress);
  }

  @override
  Future<void> onClose() async {
    await _saveProgress(
      pageIndex: lastPageIndex.value,
      positionMs: lastPositionMs.value,
      chapterProgressPercent: chapterProgressPercent.value,
    );
    _audio.isReaderActive.value = false;
    super.onClose();
  }

  Future<void> _saveProgress({
    int? pageIndex,
    int? positionMs,
    double? chapterProgressPercent,
  }) async {
    try {
      await _repository.saveProgress(
        bookId: book.id,
        chapterId: chapter.id,
        lastPositionMs: positionMs ?? lastPositionMs.value,
        lastPageIndex: pageIndex ?? lastPageIndex.value,
        chapterProgressPercent: chapterProgressPercent ?? this.chapterProgressPercent.value,
      );
    } catch (e) {
      debugPrint('Failed to save progress: $e');
    }
  }
}
