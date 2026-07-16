import 'package:book_store/core/config/app_config.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiClient {
  static ApiClient? _instance;

  late final Dio _dio;

  ApiClient._internal() {
    var baseUrl = AppConfig.apiBaseUrl;
    // Ensure paths like 'mobile/books' are appended, not replacing the /api segment.
    if (!baseUrl.endsWith('/')) {
      baseUrl = '$baseUrl/';
    }

    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (kDebugMode) {
            debugPrint('➡️ ${options.method} ${options.uri}');
          }
          if (AppConfig.apiKey.isNotEmpty) {
            options.headers['x-api-key'] = AppConfig.apiKey;
          }
          return handler.next(options);
        },
        onError: (e, handler) {
          if (kDebugMode) {
            debugPrint('❌ ${e.requestOptions.uri}: ${e.message}');
            debugPrint('Response: ${e.response?.data}');
          }
          return handler.next(e);
        },
      ),
    );
  }

  static ApiClient get instance => _instance ??= ApiClient._internal();

  Dio get dio => _dio;
}
