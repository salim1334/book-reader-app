import 'package:book_store/core/services/audio_player_service.dart';
import 'package:book_store/core/services/reading_progress_service.dart';
import 'package:book_store/data/local/models/book_local_models.dart';
import 'package:book_store/data/repositories/book_repository.dart';
import 'package:book_store/data/repositories/settings_repository.dart';
import 'package:book_store/features/chapter_reader/controllers/chapter_reader_controller.dart';
import 'package:book_store/features/chapter_reader/controllers/text_reader_controller.dart';
import 'package:book_store/features/chapter_reader/presentation/arguments/chapter_reader_args.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../../helpers/mocks.dart';
import '../../helpers/test_setup.dart';

class _TestChapterReaderController extends ChapterReaderController {
  _TestChapterReaderController(ChapterReaderArgs args) {
    book = args.book;
    chapter = args.chapter;
    initialPageIndex = args.initialPageIndex;
    initialPositionMs = args.initialPositionMs;
    chapterTitle.value = chapter.title;
    bookType.value = book.type;
    chapterKey.value = UniqueKey();
    lastPageIndex.value = initialPageIndex;
    lastPositionMs.value = initialPositionMs;
  }

  @override
  Future<void> onInit() async {
    // Avoid Get.arguments in unit tests.
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
    settings.autoScroll.value = false;
    settings.defaultSpeed.value = 1.0;

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

  group('TextReaderController', () {
    test('reload positions to initial and computes current segment', () async {
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
        contentSegments: [
          TextSegment(content: 'A', startSeconds: 0.0, endSeconds: 1.0),
          TextSegment(content: 'B', startSeconds: 1.0, endSeconds: 2.0),
        ],
      );

      when(() => repository.getChapterAssets(
            'c1',
            assetType: 'AUDIO',
          )).thenAnswer((_) async => []);
      when(() => repository.isPageFavorite(
            bookId: 'b1',
            chapterId: 'c1',
            pageIndex: 0,
          )).thenAnswer((_) async => false);

      final chapterController = _TestChapterReaderController(
        ChapterReaderArgs(
          book: book,
          chapter: chapter,
          initialPositionMs: 1500,
        ),
      );
      Get.put(chapterController);
      await chapterController.onInit();

      final controller = TextReaderController();
      Get.put(controller);
      await pumpEventQueue();
      await controller.reload();

      expect(controller.positionMs.value, 1500);
      expect(controller.hasAudio.value, false);
      expect(controller.currentSegmentIndex.value, 1);
    });
  });
}
