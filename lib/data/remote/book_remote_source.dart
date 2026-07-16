import 'package:book_store/core/config/app_config.dart';
import 'package:book_store/data/remote/api_client.dart';
import 'package:book_store/data/remote/models/remote_book.dart';

class BookRemoteSource {
  final ApiClient _client = ApiClient.instance;

  Future<List<RemoteBook>> fetchBooks() async {
    final response = await _client.dio.get(
      'mobile/books',
      queryParameters: {'authorId': AppConfig.authorId},
    );
    final list = response.data as List<dynamic>;
    return list.map((e) => RemoteBook.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<RemoteBook> fetchBook(String bookId) async {
    final response = await _client.dio.get(
      'mobile/books/$bookId',
      queryParameters: {'authorId': AppConfig.authorId},
    );
    return RemoteBook.fromJson(response.data as Map<String, dynamic>);
  }
}
