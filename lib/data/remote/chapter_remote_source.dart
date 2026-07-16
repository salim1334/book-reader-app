import 'package:book_store/core/config/app_config.dart';
import 'package:book_store/data/remote/api_client.dart';
import 'package:book_store/data/remote/models/remote_chapter.dart';

class ChapterRemoteSource {
  final ApiClient _client = ApiClient.instance;

  Future<RemoteChapter> fetchChapter(String chapterId) async {
    final response = await _client.dio.get(
      'mobile/chapters/$chapterId',
      queryParameters: {'authorId': AppConfig.authorId},
    );
    return RemoteChapter.fromJson(response.data as Map<String, dynamic>);
  }

  Future<RemoteChapter> fetchPages(String chapterId) async {
    final response = await _client.dio.get(
      'mobile/chapters/$chapterId/pages',
      queryParameters: {'authorId': AppConfig.authorId},
    );
    return RemoteChapter.fromJson(response.data as Map<String, dynamic>);
  }
}
