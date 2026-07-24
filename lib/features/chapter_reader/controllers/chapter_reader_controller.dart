import 'package:book_store/common/utils/snackbar_helper.dart';
import 'package:book_store/core/services/audio_player_service.dart';
import 'package:book_store/core/services/reading_progress_service.dart';
import 'package:book_store/data/local/models/book_local_models.dart';
import 'package:book_store/data/repositories/book_repository.dart';
import 'package:book_store/data/repositories/settings_repository.dart';
import 'package:book_store/features/chapter_reader/controllers/image_reader_controller.dart';
import 'package:book_store/features/chapter_reader/controllers/text_reader_controller.dart';
import 'package:book_store/features/chapter_reader/presentation/arguments/chapter_reader_args.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class ChapterReaderController extends GetxController {
  final BookRepository _repository = Get.find<BookRepository>();
  final AudioPlayerService _audio = Get.find<AudioPlayerService>();
  final SettingsRepository _settings = Get.find<SettingsRepository>();
  final ReadingProgressService _progressService = Get.find<ReadingProgressService>();

  late LocalBook book;
  late LocalChapter chapter;
  late int initialPageIndex;
  late int initialPositionMs;

  final chapterTitle = ''.obs;
  final bookType = LocalBookType.text.obs;
  final chapterKey = UniqueKey().obs;

  final lastPageIndex = 0.obs;
  final lastPositionMs = 0.obs;
  final chapterProgressPercent = 0.0.obs;
  final isPageFavorite = false.obs;

  /// When true the reader hides the app bar, audio player and system UI for
  /// an immersive full-screen experience. A tap on the content toggles it.
  final isImmersiveMode = false.obs;

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
    chapterTitle.value = chapter.title;
    bookType.value = book.type;
    chapterKey.value = UniqueKey();

    lastPageIndex.value = initialPageIndex;
    lastPositionMs.value = initialPositionMs;

    _audio.onQueueCompleted = () { _onAudioFinished(); };
    _audio.onSkipToNext = _skipToNextChapter;
    _audio.onSkipToPrevious = _skipToPreviousChapter;

    await _loadPageFavoriteState();
    await _saveProgress(
      pageIndex: initialPageIndex,
      positionMs: initialPositionMs,
      chapterProgressPercent: 0.0,
    );
  }

  Future<void> updatePage(int pageIndex) async {
    lastPageIndex.value = pageIndex;
    await _loadPageFavoriteState();
    await _saveProgress(pageIndex: pageIndex);
  }

  /// Toggles immersive reading mode (full-screen, no app bar/audio player).
  void toggleImmersiveMode() {
    isImmersiveMode.toggle();
    _applySystemUI();
  }

  void setImmersiveMode(bool immersive) {
    if (isImmersiveMode.value == immersive) return;
    isImmersiveMode.value = immersive;
    _applySystemUI();
  }

  void _applySystemUI() {
    if (isImmersiveMode.value) {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.immersiveSticky,
      );
    } else {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.edgeToEdge,
        overlays: SystemUiOverlay.values,
      );
    }
  }

  /// Allow both portrait and landscape while reading.
  Future<void> enableReaderOrientations() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  /// Reset to portrait when leaving the reader.
  Future<void> resetOrientations() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: SystemUiOverlay.values,
    );
  }

  Future<void> _loadPageFavoriteState() async {
    try {
      isPageFavorite.value = await _repository.isPageFavorite(
        bookId: book.id,
        chapterId: chapter.id,
        pageIndex: lastPageIndex.value,
      );
    } catch (e) {
      debugPrint('Failed to load page favorite state: $e');
    }
  }

  Future<void> togglePageFavorite() async {
    final newValue = !isPageFavorite.value;
    await _repository.setPageFavorite(
      bookId: book.id,
      chapterId: chapter.id,
      pageIndex: lastPageIndex.value,
      favorite: newValue,
    );
    isPageFavorite.value = newValue;
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
    _audio.onQueueCompleted = null;
    _audio.onSkipToNext = null;
    _audio.onSkipToPrevious = null;
    await _saveProgress(
      pageIndex: lastPageIndex.value,
      positionMs: lastPositionMs.value,
      chapterProgressPercent: chapterProgressPercent.value,
    );
    await resetOrientations();
    super.onClose();
  }

  /// Handles completion of the current audio queue. If Auto-Play Next is on
  /// and the next chapter is downloaded, load it in place.
  Future<void> _onAudioFinished() async {
    if (!_settings.autoPlayNext.value) return;
    await _skipToNextChapter();
  }

  Future<void> _skipToNextChapter() async {
    final chapters = await _repository.getChapters(book.id);
    final currentIndex = chapters.indexWhere((c) => c.id == chapter.id);
    if (currentIndex < 0 || currentIndex >= chapters.length - 1) return;

    final next = chapters[currentIndex + 1];
    if (!next.isDownloaded) {
      SnackbarHelper.show('Next chapter is not downloaded.');
      return;
    }

    await loadChapter(next);
  }

  Future<void> _skipToPreviousChapter() async {
    final chapters = await _repository.getChapters(book.id);
    final currentIndex = chapters.indexWhere((c) => c.id == chapter.id);
    if (currentIndex <= 0) return;

    final previous = chapters[currentIndex - 1];
    if (!previous.isDownloaded) {
      SnackbarHelper.show('Previous chapter is not downloaded.');
      return;
    }

    await loadChapter(previous);
  }

  /// Reload the reader for a new chapter without replacing the route, avoiding
  /// GetX controller lifetime issues when navigating to the same page.
  Future<void> loadChapter(LocalChapter newChapter) async {
    chapter = newChapter;
    initialPageIndex = 0;
    initialPositionMs = 0;

    lastPageIndex.value = 0;
    lastPositionMs.value = 0;
    chapterProgressPercent.value = 0.0;
    isPageFavorite.value = false;

    await _loadPageFavoriteState();
    await _saveProgress(
      pageIndex: 0,
      positionMs: 0,
      chapterProgressPercent: 0.0,
    );

    if (book.type == LocalBookType.text) {
      await Get.find<TextReaderController>().reload();
    } else {
      await Get.find<ImageReaderController>().reload();
    }

    chapterTitle.value = newChapter.title;
    bookType.value = book.type;
    chapterKey.value = UniqueKey();
  }

  Future<void> _saveProgress({
    int? pageIndex,
    int? positionMs,
    double? chapterProgressPercent,
  }) async {
    try {
      await _progressService.saveProgress(
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
