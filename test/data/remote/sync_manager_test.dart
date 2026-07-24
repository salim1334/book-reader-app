import 'package:book_store/core/services/notification_service.dart';
import 'package:book_store/data/local/daos/book_dao.dart';
import 'package:book_store/data/local/models/book_local_models.dart';
import 'package:book_store/data/remote/models/remote_book.dart';
import 'package:book_store/data/remote/models/remote_chapter.dart';
import 'package:book_store/data/remote/sync_manager.dart';
import 'package:book_store/data/repositories/settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mocks.dart';
import '../../helpers/test_setup.dart';

void main() {
  setupTestBinding();

  late FakeBookRemoteSource bookRemote;
  late FakeChapterRemoteSource chapterRemote;
  late FakeDownloadManager downloadManager;
  late MockBookDao dao;
  late MockNotificationService notificationService;
  late SettingsRepository settings;
  late FakeSyncManager syncManager;

  setUp(() async {
    resetGetX();
    bookRemote = FakeBookRemoteSource();
    chapterRemote = FakeChapterRemoteSource();
    downloadManager = FakeDownloadManager();
    dao = MockBookDao();
    notificationService = MockNotificationService();

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
    when(() => settingsDao.getBool(any(), defaultValue: any(named: 'defaultValue')))
        .thenAnswer((_) async => false);
    when(() => settingsDao.getDouble(any())).thenAnswer((_) async => null);
    settings = SettingsRepository(dao: settingsDao);
    await settings.onInit();
    settings.offlineMode.value = false;

    Get.put<SettingsRepository>(settings, permanent: true);
    Get.put<NotificationService>(notificationService, permanent: true);

    syncManager = FakeSyncManager(
      bookRemote,
      chapterRemote,
      downloadManager,
      dao: dao,
    );
    syncManager.isOnlineResult = true;
    syncManager.delegateSyncCatalog = true;

    // Default stubbing for dao
    when(() => dao.getBook(any())).thenAnswer((_) async => null);
    when(() => dao.getChapter(any())).thenAnswer((_) async => null);
    when(() => dao.insertBook(any())).thenAnswer((_) async {});
    when(() => dao.updateBookInfo(any())).thenAnswer((_) async {});
    when(() => dao.updateBookMetadata(any())).thenAnswer((_) async {});
    when(() => dao.insertChapter(any())).thenAnswer((_) async {});
    when(() => dao.updateChapterInfo(any())).thenAnswer((_) async {});
    when(() => dao.updateChapterMetadata(any())).thenAnswer((_) async {});
    when(() => dao.updateBookCover(any(), any())).thenAnswer((_) async {});
    when(() => dao.updateChapterContent(
          any(),
          contentText: any(named: 'contentText'),
          contentSegmentsJson: any(named: 'contentSegmentsJson'),
        )).thenAnswer((_) async {});
    when(() => dao.markChapterDownloaded(any(), any())).thenAnswer((_) async {});
    when(() => dao.getDownloadedAssets(any(), assetType: any(named: 'assetType')))
        .thenAnswer((_) async => []);
    when(() => dao.deleteDownloadedAssets(any())).thenAnswer((_) async {});
    when(
      () => dao.insertDownloadedAsset(
        chapterId: any(named: 'chapterId'),
        assetType: any(named: 'assetType'),
        filePath: any(named: 'filePath'),
        sortOrder: any(named: 'sortOrder'),
        audioStartTime: any(named: 'audioStartTime'),
        audioEndTime: any(named: 'audioEndTime'),
      ),
    ).thenAnswer((_) async {});

    when(() => notificationService.showNewBookNotification(any()))
        .thenAnswer((_) async {});
    when(() => notificationService.showUpdateNotification(any()))
        .thenAnswer((_) async {});
  });

  group('SyncManager.syncCatalog', () {
    test('downloads metadata and inserts new books and chapters', () async {
      bookRemote.addBook(
        RemoteBook(
          id: 'b1',
          title: 'New Book',
          type: 'TEXT',
          version: 1,
          author: RemoteAuthor(id: 'a1', name: 'Author'),
          published: true,
          chapters: [
            RemoteChapterSummary(
              id: 'c1',
              title: 'Chapter 1',
              orderIndex: 0,
              version: 1,
            ),
          ],
        ),
      );

      await syncManager.syncCatalog();

      verify(() => dao.insertBook(any())).called(1);
      verify(() => dao.insertChapter(any())).called(1);
      expect(syncManager.syncState.value, SyncState.idle);
    });

    test('shows notification for new books when notify is true', () async {
      bookRemote.addBook(
        RemoteBook(
          id: 'b1',
          title: 'New Book',
          type: 'TEXT',
          version: 1,
          author: RemoteAuthor(id: 'a1', name: 'Author'),
          published: true,
        ),
      );
      settings.notifyNewBooks.value = true;

      await syncManager.syncCatalog();

      verify(() => notificationService.showNewBookNotification('New Book'))
          .called(1);
    });
  });

  group('SyncManager.downloadBook', () {
    setUp(() => syncManager.delegateDownloadChapter = true);

    test('downloads cover and a single text chapter', () async {
      bookRemote.addBook(
        RemoteBook(
          id: 'b1',
          title: 'Book',
          type: 'TEXT',
          version: 1,
          author: RemoteAuthor(id: 'a1', name: 'Author'),
          coverImage: '/uploads/cover.jpg',
          published: true,
          chapters: [
            RemoteChapterSummary(
              id: 'c1',
              title: 'Chapter 1',
              orderIndex: 0,
              version: 1,
            ),
          ],
        ),
      );

      chapterRemote.addChapter(
        RemoteChapter(
          id: 'c1',
          bookId: 'b1',
          title: 'Chapter 1',
          orderIndex: 0,
          version: 1,
          texts: [
            RemoteTextPage(
              id: 't1',
              chapterId: 'c1',
              content: 'Hello world',
              orderIndex: 0,
              version: 1,
            ),
          ],
        ),
      );

      await syncManager.downloadBook('b1');

      verify(() => dao.updateBookCover('b1', any())).called(1);
      verify(
        () => dao.updateChapterContent(
          'c1',
          contentText: any(named: 'contentText'),
          contentSegmentsJson: any(named: 'contentSegmentsJson'),
        ),
      ).called(1);
      verify(() => dao.markChapterDownloaded('c1', true)).called(1);
      expect(syncManager.bookDownloadProgress['b1'], 1.0);
    });

    test('throws if book is not published', () async {
      bookRemote.addBook(
        RemoteBook(
          id: 'b1',
          title: 'Book',
          type: 'TEXT',
          version: 1,
          author: RemoteAuthor(id: 'a1', name: 'Author'),
          published: false,
        ),
      );

      expect(
        () => syncManager.downloadBook('b1'),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('SyncManager.downloadChapter', () {
    setUp(() => syncManager.delegateDownloadChapter = true);

    test('downloads images and audio assets', () async {
      chapterRemote.addChapter(
        RemoteChapter(
          id: 'c1',
          bookId: 'b1',
          title: 'Chapter 1',
          orderIndex: 0,
          version: 1,
          pages: [
            RemotePage(
              id: 'p1',
              chapterId: 'c1',
              imagePath: '/uploads/images/b1/c1/page.jpg',
              orderIndex: 0,
              version: 1,
            ),
          ],
          audios: [
            RemoteAudio(
              id: 'a1',
              chapterId: 'c1',
              audioPath: '/uploads/audio/b1/c1/audio.mp3',
              duration: 120,
              version: 1,
            ),
          ],
        ),
      );

      await syncManager.downloadChapter('c1');

      verify(
        () => dao.insertDownloadedAsset(
          chapterId: 'c1',
          assetType: 'IMAGE',
          filePath: any(named: 'filePath'),
          sortOrder: any(named: 'sortOrder'),
          audioStartTime: any(named: 'audioStartTime'),
          audioEndTime: any(named: 'audioEndTime'),
        ),
      ).called(1);
      verify(
        () => dao.insertDownloadedAsset(
          chapterId: 'c1',
          assetType: 'AUDIO',
          filePath: any(named: 'filePath'),
          sortOrder: any(named: 'sortOrder'),
          audioStartTime: any(named: 'audioStartTime'),
          audioEndTime: any(named: 'audioEndTime'),
        ),
      ).called(1);
    });
  });
}
