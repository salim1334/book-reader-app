import 'package:book_store/app.dart';
import 'package:book_store/core/bindings/app_binding.dart';
import 'package:book_store/core/config/app_config.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AppConfig.validate();

  AppBinding.preInit();

  runApp(const App());
}
