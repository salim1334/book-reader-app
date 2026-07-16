import 'dart:io';

import 'package:book_store/core/utils/asset_url.dart';
import 'package:book_store/data/remote/api_client.dart';
import 'package:path_provider/path_provider.dart';

/// Manages downloading remote media files to device storage.
class DownloadManager {
  final ApiClient _client = ApiClient.instance;

  /// Returns a local file path where the asset should be stored.
  Future<String> _localPath(
    String assetType,
    String bookId,
    String chapterId,
    String remotePath,
  ) async {
    final dir = await getApplicationDocumentsDirectory();
    final folder = Directory(
      '${dir.path}/downloads/$assetType/$bookId/$chapterId',
    );
    if (!folder.existsSync()) {
      await folder.create(recursive: true);
    }
    final fileName = remotePath.split('/').last;
    return '${folder.path}/$fileName';
  }

  /// Downloads an asset from a remote path and returns the local path.
  /// The remotePath is expected to be a relative path such as
  /// `/uploads/images/{bookId}/{chapterId}/{fileName}`.
  Future<String> downloadAsset({
    required String assetType,
    required String bookId,
    required String chapterId,
    required String remotePath,
    void Function(int received, int total)? onProgress,
  }) async {
    final localFilePath = await _localPath(assetType, bookId, chapterId, remotePath);
    final localFile = File(localFilePath);

    if (localFile.existsSync()) {
      // Optionally check size/hash here if caching logic needs invalidation.
      return localFilePath;
    }

    final url = resolveAssetUrl(remotePath);
    final response = await _client.dio.download(
      url,
      localFilePath,
      onReceiveProgress: (received, total) {
        if (total != -1) {
          onProgress?.call(received, total);
        }
      },
    );

    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      return localFilePath;
    }

    throw Exception('Failed to download $remotePath: ${response.statusCode}');
  }

  Future<void> deleteAsset(String localPath) async {
    final file = File(localPath);
    if (file.existsSync()) {
      await file.delete();
    }
  }

  /// Deletes all downloaded assets for a single book.
  Future<void> deleteBookAssets(String bookId) async {
    final dir = await getApplicationDocumentsDirectory();
    for (final type in ['images', 'audio']) {
      final folder = Directory('${dir.path}/downloads/$type/$bookId');
      if (folder.existsSync()) {
        await folder.delete(recursive: true);
      }
    }
  }

  /// Deletes the entire downloaded media directory.
  Future<void> clearDownloads() async {
    final dir = await getApplicationDocumentsDirectory();
    final folder = Directory('${dir.path}/downloads');
    if (folder.existsSync()) {
      await folder.delete(recursive: true);
    }
  }
}
