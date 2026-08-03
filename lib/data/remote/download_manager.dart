import 'dart:io';

import 'package:book_store/core/constants/app_texts.dart';
import 'package:book_store/core/exceptions/storage_exceptions.dart';
import 'package:book_store/core/utils/asset_url.dart';
import 'package:book_store/data/remote/api_client.dart';
import 'package:dio/dio.dart';
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

  Future<void> _deleteIfEmpty(File file) async {
    if (file.existsSync()) {
      if (file.lengthSync() == 0) {
        await file.delete();
      }
    }
  }

  Future<void> _safeDelete(File file) async {
    if (file.existsSync()) {
      await file.delete();
    }
  }

  /// Tries to get the expected file size from the server without downloading
  /// the body. Returns `null` if the server does not report it.
  Future<int?> _fetchContentLength(
    String url, {
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _client.dio.head(
        url,
        cancelToken: cancelToken,
      );
      final header = response.headers.value('content-length');
      if (header != null) return int.tryParse(header);
    } catch (_) {
      // Fall back to re-download if the server does not support HEAD.
    }
    return null;
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
    CancelToken? cancelToken,
  }) async {
    final localFilePath = await _localPath(assetType, bookId, chapterId, remotePath);
    final localFile = File(localFilePath);

    await _deleteIfEmpty(localFile);

    final url = resolveAssetUrl(remotePath);

    if (localFile.existsSync()) {
      final expectedSize = await _fetchContentLength(
        url,
        cancelToken: cancelToken,
      );
      final actualSize = localFile.lengthSync();
      if (expectedSize == null) {
        // Cannot verify: re-download to be safe.
        await _safeDelete(localFile);
      } else if (actualSize == expectedSize) {
        return localFilePath;
      } else {
        await _safeDelete(localFile);
      }
    }
    try {
      final response = await _client.dio.download(
        url,
        localFilePath,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            onProgress?.call(received, total);
          }
        },
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        // Guard against 0-byte or unexpectedly small writes.
        if (!localFile.existsSync() || localFile.lengthSync() == 0) {
          await _safeDelete(localFile);
          throw Exception('Downloaded file is empty: $remotePath');
        }
        return localFilePath;
      }

      await _safeDelete(localFile);
      throw Exception('Failed to download $remotePath: ${response.statusCode}');
    } catch (e) {
      await _safeDelete(localFile);
      if (_isStorageFullError(e)) {
        throw const StorageFullException(
          AppTexts.storageFullMessage,
        );
      }
      rethrow;
    }
  }

  /// Returns true if [error] indicates the write failed because the device is
  /// out of storage space. This covers common OS error strings and error codes.
  bool _isStorageFullError(Object error) {
    final text = error.toString().toLowerCase();
    const patterns = [
      'no space left',
      'not enough space',
      'storage full',
      'disk full',
      'insufficient storage',
      'enospc',
      'error 112', // windows error_disk_full
    ];
    for (final pattern in patterns) {
      if (text.contains(pattern)) return true;
    }

    final underlying = error is DioException ? error.error : null;
    if (underlying != null) return _isStorageFullError(underlying);
    return false;
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

  Future<void> deleteChapterAssets(String chapterId) async {
    final dir = await getApplicationDocumentsDirectory();
    for (final type in ['images', 'audio']) {
      final folder = Directory('${dir.path}/downloads/$type');
      if (folder.existsSync()) {
        final subfolders = folder.listSync();
        for (final subfolder in subfolders) {
          if (subfolder is Directory) {
            final chapterFolder = Directory('${subfolder.path}/$chapterId');
            if (chapterFolder.existsSync()) {
              await chapterFolder.delete(recursive: true);
            }
          }
        }
      }
    }
  }
}
