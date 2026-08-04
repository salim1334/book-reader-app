import 'package:book_store/app.dart';
import 'package:book_store/core/bindings/app_binding.dart';
import 'package:book_store/core/config/app_config.dart';
import 'package:book_store/data/local/daos/book_dao.dart';
import 'package:book_store/data/local/database_helper.dart';
import 'package:book_store/data/local/services/bundled_content_seeder.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AppConfig.validate();

  final db = await DatabaseHelper.instance.database;
  await BundledContentSeeder(BookDao(db)).seedIfNeeded();

  // Initialize core services
  await AppBinding.init();

  runApp(const App());
}
