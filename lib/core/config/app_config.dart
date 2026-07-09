import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract final class AppConfig {
  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'https://api.example.com';

  static String get apiKey {
    try {
      return dotenv.env['API_KEY'] ?? '';
    } catch (_) {
      // dotenv might not be initialized (e.g. .env missing). Fall back to defaults.
      return '';
    }
  }

  static String get appEnv => dotenv.env['APP_ENV'] ?? 'development';

  static bool get isDev => appEnv.toLowerCase() == 'development';

  static void validate() {
    if (kDebugMode && apiKey.isEmpty) {
      debugPrint(
        'AppConfig: API_KEY is empty. Copy .env.example to .env for local development.',
      );
    }
  }

  static String maskedApiKey() {
    if (apiKey.length <= 4) return '****';
    return '${apiKey.substring(0, 2)}****${apiKey.substring(apiKey.length - 2)}';
  }
}
