import 'package:book_store/core/services/audio_player_service.dart';
import 'package:book_store/core/services/reading_progress_service.dart';
import 'package:book_store/data/local/models/book_local_models.dart';
import 'package:book_store/data/repositories/book_repository.dart';
import 'package:book_store/data/repositories/settings_repository.dart';
import 'package:book_store/features/chapter_reader/controllers/chapter_reader_controller.dart';
import 'package:book_store/features/chapter_reader/presentation/arguments/chapter_reader_args.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../../helpers/mocks.dart';
import '../../helpers/test_setup.dart';

class _TestChapterReaderController extends ChapterReaderController {
  final ChapterReaderArgs _args;

  _TestChapterReaderController(this._args);

  @override
  Future<void> onInit() async {
    final args = _args;
    book = args.book;
    chapter = args.chapter;
    initialPageIndex = args.initialPageIndex;
    initialPositionMs = args.initialPositionMs;
    chapterTitle.value = chapter.title;
    bookType.value = book.type;
    chapterKey.value = UniqueKey();
    lastPageIndex.value = initialPageIndex;
    lastPositionMs.value = initialPositionMs;

    final audio = Get.find<AudioPlayerService>();
    audio.onQueueCompleted = () => _onAudioFinished();
    audio.onSkipToNext = _skipToNextChapter;
    audio.onSkipToPrevious = _skipToPreviousChapter;
  }
}

void main() {
  setupTestBinding();

  late MockBookRepository repository;
  late FakeAudioPlayerService audio;
  late SettingsRepository settings;
  late MockReadingProgressService progressService;

  setUp(() async {
    resetGetX();
    repository = MockBookRepository();
    audio = FakeAudioPlayerService();
    progressService = MockReadingProgressService();

    final settingsDao = MockSettingsDao();
    when(() => settingsDao.getString('theme_mode'))
        .thenAnswer((_) async => null);
    for (final key in [
      'font_size',
      'font_size_slider',
      'auto_scroll',
      'default_speed',
      'auto_play_next',
      'offline_mode',
      'auto_download',
      'notify_new_books',
      'notify_updates',
    ]) {
      when(() => settingsDao.getString(key)).thenAnswer((_) async => null);
    }
    when(
      () => settingsDao.getBool(any(), defaultValue: any(named: 'defaultValue')),
    ).thenAnswer((_) async => false);
    when(() => settingsDao.getDouble(any())).thenAnswer((_) async => null);
    settings = SettingsRepository(dao: settingsDao);
    await settings.onInit();
    settings.autoPlayNext.value = false;
    settings.autoScroll.value = false;

    when(() => progressService.saveProgress(
          bookId: any(named: 'bookId'),
          chapterId: any(named: 'chapterId'),
          lastPositionMs: any(named: 'lastPositionMs'),
          lastPageIndex: any(named: 'lastPageIndex'),
          chapterProgressPercent: any(named: 'chapterProgressPercent'),
        )).thenAnswer((_) async {});

    Get.put<BookRepository>(repository, permanent: true);
    Get.put<AudioPlayerService>(audio, permanent: true);
    Get.put<SettingsRepository>(settings, permanent: true);
    Get.put<ReadingProgressService>(progressService, permanent: true);
  });

  group('ChapterReaderController', () {
    test('onInit sets initial values', () async {
      const book = LocalBook(
        id: 'b1',
        title: 'Book',
        type: LocalBookType.text,
        version: 1,
      );
      const chapter = LocalChapter(
        id: 'c1',
        bookId: 'b1',
        title: 'Ch1',
        sortOrder: 0,
        version: 1,
      );

      final controller = _TestChapterReaderController(
        ChapterReaderArgs(book: book, chapter: chapter, initialPageIndex: 2),
      );
      await controller.onInit();

      expect(controller.book.id, 'b1');
      expect(controller.chapter.id, 'c1');
      expect(controller.lastPageIndex.value, 2);
    });

    test('updatePage updates page and favorite state', () async {
      const book = LocalBook(
        id: 'b1',
        title: 'Book',
        type: LocalBookType.text,
        version: 1,
      );
      const chapter = LocalChapter(
        id: 'c1',
        bookId: 'b1',
        title: 'Ch1',
        sortOrder: 0,
        version: 1,
      );

      when(() => repository.isPageFavorite(
            bookId: 'b1',
            chapterId: 'c1',
            pageIndex: 3,
          )).thenAnswer((_) async => true);

      final controller = _TestChapterReaderController(
        ChapterReaderArgs(book: book, chapter: chapter),
      );
      await controller.onInit();

      await controller.updatePage(3);

      expect(controller.lastPageIndex.value, 3);
      expect(controller.isPageFavorite.value, true);
      verify(() => progressService.saveProgress(
            bookId: 'b1',
            chapterId: 'c1',
            lastPositionMs: 0,
            lastPageIndex: 3,
            chapterProgressPercent: 0.0,
          )).called(1);
    });

    test('togglePageFavorite flips state and persists', () async {
      const book = LocalBook(
        id: 'b1',
        title: 'Book',
        type: LocalBookType.text,
        version: 1,
      );
      const chapter = LocalChapter(
        id: 'c1',
        bookId: 'b1',
        title: 'Ch1',
        sortOrder: 0,
        version: 1,
      );

      when(() => repository.isPageFavorite(
            bookId: 'b1',
            chapterId: 'c1',
            pageIndex: 0,
          )).thenAnswer((_) async => false);
      when(() => repository.setPageFavorite(
            bookId: 'b1',
            chapterId: 'c1',
            pageIndex: 0,
            favorite: true,
          )).thenAnswer((_) async {});

      final controller = _TestChapterReaderController(
        ChapterReaderArgs(book: book, chapter: chapter),
      );
      await controller.onInit();

      await controller.togglePageFavorite();

      expect(controller.isPageFavorite.value, true);
      verify(() => repository.setPageFavorite(
            bookId: 'b1',
            chapterId: 'c1',
            pageIndex: 0,
            favorite: true,
          )).called(1);
    });
  });
}
