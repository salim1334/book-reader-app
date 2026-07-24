import 'package:book_store/app.dart';
import 'package:book_store/core/bindings/app_binding.dart';
import 'package:book_store/core/config/app_config.dart';
import 'package:book_store/data/local/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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

  // Initialize core services
  await AppBinding.init();

  runApp(const App());
}
