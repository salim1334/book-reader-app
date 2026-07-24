import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract final class AppConfig {
  static String _safeGet(String key, String fallback) {
    try {
      return dotenv.env[key] ?? fallback;
    } catch (_) {
      // dotenv might not be initialized (e.g. .env missing). Fall back to defaults.
      return fallback;
    }
  }

  static String get apiBaseUrl => _safeGet('API_BASE_URL', 'https://api.islamickitab.com/api/');

  static String get authorId => _safeGet('AUTHOR_ID', 'cmroh7yas000gbjo8apaz4lm3');

  static String get apiKey => _safeGet('API_KEY', 'your-shared-key');

  static String get appEnv => _safeGet('APP_ENV', 'Production');

  static bool get isDev => appEnv.toLowerCase() == 'Production';

  static void validate() {
    if (kDebugMode && apiKey.isEmpty) {
      debugPrint(
        'AppConfig: API_KEY is empty. Copy .env.example to .env for local development.',
      );
    }
    if (kDebugMode && authorId.isEmpty) {
      debugPrint(
        'AppConfig: AUTHOR_ID is empty. Set AUTHOR_ID in .env so the app knows which author it belongs to.',
      );
    }
    if (kDebugMode && apiBaseUrl == 'https://api.islamickitab.com/api/') {
      debugPrint(
        'AppConfig: API_BASE_URL is still the placeholder. Update .env to point to your admin panel.',
      );
    }
  }

  static String maskedApiKey() {
    if (apiKey.length <= 4) return '****';
    return '${apiKey.substring(0, 2)}****${apiKey.substring(apiKey.length - 2)}';
  }
}
