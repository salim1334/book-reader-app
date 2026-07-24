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
  static Future<void> init() async {
    // Core services
    Get.put(SettingsRepository(), permanent: true);

    await Get.putAsync<BookRepository>(
      () async => BookRepository().init(),
      permanent: true,
    );
    await Get.putAsync<AudioPlayerService>(
      () async => AudioPlayerService().init(),
      permanent: true,
    );
    Get.put(ReadingProgressService(), permanent: true);
    Get.put(FavoritesController(), permanent: true);

    await Get.putAsync<NotificationService>(
      () async => NotificationService().init(),
      permanent: true,
    );

    // Remote services
    Get.put(BookRemoteSource(), permanent: true);
    Get.put(ChapterRemoteSource(), permanent: true);
    Get.put(DownloadManager(), permanent: true);
    await Get.putAsync<SyncManager>(
      () async => SyncManager.init(),
      permanent: true,
    );
  }
}
