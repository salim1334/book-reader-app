import 'package:book_store/app.dart';
import 'package:book_store/core/config/app_config.dart';
import 'package:book_store/data/local/database_helper.dart';
import 'package:book_store/data/remote/book_remote_source.dart';
import 'package:book_store/data/remote/chapter_remote_source.dart';
import 'package:book_store/data/remote/download_manager.dart';
import 'package:book_store/data/remote/sync_manager.dart';
import 'package:book_store/data/repositories/book_repository.dart';
import 'package:book_store/data/repositories/settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load env for local development. If .env is missing, initialize dotenv
  // with an empty map so the app can fall back to defaults without crashing.
  try {
    await dotenv.load(fileName: '.env', isOptional: true);
  } catch (_) {
    dotenv.loadFromString(envString: '');
  }
  AppConfig.validate();

  await DatabaseHelper.instance.database;

  // Core services
  Get.put(SettingsRepository(), permanent: true);
  await Get.putAsync<BookRepository>(
    () async => BookRepository().init(),
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

  runApp(const App());
}
