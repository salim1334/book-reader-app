import 'package:book_store/core/services/audio_player_service.dart';
import 'package:book_store/core/services/reading_progress_service.dart';
import 'package:book_store/data/local/models/book_local_models.dart';
import 'package:book_store/data/repositories/book_repository.dart';
import 'package:book_store/data/repositories/settings_repository.dart';
import 'package:book_store/features/chapter_reader/controllers/chapter_reader_controller.dart';
import 'package:book_store/features/chapter_reader/controllers/image_reader_controller.dart';
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

  group('ImageReaderController', () {
    test('reload loads image media and initializes page controller', () async {
      const book = LocalBook(
        id: 'b1',
        title: 'Book',
        type: LocalBookType.image,
        version: 1,
      );
      const chapter = LocalChapter(
        id: 'c1',
        bookId: 'b1',
        title: 'Ch1',
        sortOrder: 0,
        version: 1,
      );

      when(() => repository.getChapterAssets('c1', assetType: 'IMAGE'))
          .thenAnswer((_) async => [
                {
                  'file_path': '/img1.jpg',
                  'sort_order': 0,
                },
                {
                  'file_path': '/img2.jpg',
                  'sort_order': 1,
                },
              ]);
      when(() => repository.getChapterAssets('c1', assetType: 'AUDIO'))
          .thenAnswer((_) async => []);

      final chapterController = _TestChapterReaderController(
        ChapterReaderArgs(book: book, chapter: chapter, initialPageIndex: 1),
      );
      Get.put(chapterController);

      final controller = ImageReaderController();
      Get.put(controller);
      await pumpEventQueue();
      await controller.reload();

      expect(controller.imageCount.value, 2);
      expect(controller.currentPageIndex.value, 1);
      expect(controller.media.value?.images, ['/img1.jpg', '/img2.jpg']);
      expect(controller.isLoading.value, false);
    });

    test('onPageChanged reports progress and updates chapter reader', () async {
      const book = LocalBook(
        id: 'b1',
        title: 'Book',
        type: LocalBookType.image,
        version: 1,
      );
      const chapter = LocalChapter(
        id: 'c1',
        bookId: 'b1',
        title: 'Ch1',
        sortOrder: 0,
        version: 1,
      );

      when(() => repository.getChapterAssets('c1', assetType: 'IMAGE'))
          .thenAnswer((_) async => [
                {'file_path': '/img1.jpg', 'sort_order': 0},
                {'file_path': '/img2.jpg', 'sort_order': 1},
              ]);
      when(() => repository.getChapterAssets('c1', assetType: 'AUDIO'))
          .thenAnswer((_) async => []);

      final chapterController = _TestChapterReaderController(
        ChapterReaderArgs(book: book, chapter: chapter),
      );
      Get.put(chapterController);

      final controller = ImageReaderController();
      Get.put(controller);
      await pumpEventQueue();
      await controller.reload();

      controller.onPageChanged(0);

      expect(controller.currentPageIndex.value, 0);
      expect(chapterController.lastPageIndex.value, 0);
      verify(() => progressService.saveProgress(
            bookId: 'b1',
            chapterId: 'c1',
            lastPositionMs: 0,
            lastPageIndex: 0,
            chapterProgressPercent: any(named: 'chapterProgressPercent'),
          )).called(2);
    });
  });
}
