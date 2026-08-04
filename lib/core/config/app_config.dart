import 'package:flutter/foundation.dart';

abstract final class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://admin.islamickitab.com/api/',
  );

  static const String authorId = String.fromEnvironment(
    'AUTHOR_ID',
    defaultValue: 'cmroh7yas000gbjo8apaz4lm3',
  );

  static const String apiKey = String.fromEnvironment(
    'API_KEY',
    defaultValue: 'your-shared-key',
  );

  static const String appEnv = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'Production',
  );

  static bool get isDev => appEnv.toLowerCase() == 'development';

  static void validate() {
    if (kDebugMode && apiKey.isEmpty) {
      debugPrint(
        'AppConfig: API_KEY is empty. Pass --dart-define=API_KEY=... when building.',
      );
    }

    if (kDebugMode && authorId.isEmpty) {
      debugPrint(
        'AppConfig: AUTHOR_ID is empty. Pass --dart-define=AUTHOR_ID=... when building.',
      );
    }

    if (kDebugMode && apiBaseUrl == 'https://admin.islamickitab.com/api/') {
      debugPrint(
        'AppConfig: API_BASE_URL is still the placeholder. Pass --dart-define=API_BASE_URL=... when building.',
      );
    }
  }

  static String maskedApiKey() {
    if (apiKey.length <= 4) return '****';

    return '${apiKey.substring(0, 2)}****${apiKey.substring(apiKey.length - 2)}';
  }
}
