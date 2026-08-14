import 'package:book_store/core/services/audio_player_service.dart';
import 'package:book_store/core/services/notification_service.dart';
import 'package:book_store/core/services/reading_progress_service.dart';
import 'package:book_store/data/remote/book_remote_source.dart';
import 'package:book_store/data/remote/chapter_remote_source.dart';
import 'package:book_store/data/remote/download_manager.dart';
import 'package:book_store/data/remote/sync_manager.dart';
import 'package:book_store/data/repositories/book_repository.dart';
import 'package:book_store/data/repositories/settings_repository.dart';
import 'package:book_store/features/favorites/controllers/favorites_controller.dart';
import 'package:get/get.dart';

abstract final class AppBinding {
  /// Synchronous registrations the app shell needs before the first frame.
  /// Put anything accessed by [App], [AudioPlayerOverlay], or the splash here.
  static void preInit() {
    Get.put(SettingsRepository(), permanent: true);
    Get.put(AudioPlayerService(), permanent: true);
    Get.put(BookRemoteSource(), permanent: true);
    Get.put(ChapterRemoteSource(), permanent: true);
    Get.put(DownloadManager(), permanent: true);
    Get.put(NotificationService(), permanent: true);
  }

  /// Asynchronous initializations that run behind the splash screen.
  static Future<void> asyncInit() async {
    await Get.putAsync<BookRepository>(
      () async => BookRepository().init(),
      permanent: true,
    );
    Get.put(ReadingProgressService(), permanent: true);
    Get.put(FavoritesController(), permanent: true);
    await Get.find<AudioPlayerService>().init();
    await Get.find<NotificationService>().init();
    await Get.putAsync<SyncManager>(
      () async => SyncManager.init(),
      permanent: true,
    );
  }
}
