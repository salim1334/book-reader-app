import 'package:book_store/app.dart';
import 'package:book_store/core/config/app_config.dart';
import 'package:book_store/data/local/database_helper.dart';
import 'package:book_store/data/repositories/book_repository.dart';
import 'package:book_store/data/repositories/settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load env for local development.
  // If .env is missing (common in fresh checkouts), continue with defaults.
  await dotenv.load(fileName: '.env').catchError((_) {});
  AppConfig.validate();


  await DatabaseHelper.instance.database;
  Get.put(SettingsRepository(), permanent: true);
  await Get.putAsync<BookRepository>(() async => BookRepository().init());

  runApp(const App());
}
