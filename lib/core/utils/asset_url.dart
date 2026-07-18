import 'dart:io';

import 'package:book_store/data/local/models/book_local_models.dart';
import 'package:book_store/data/remote/api_client.dart';
import 'package:flutter/painting.dart';

/// Converts a relative server asset path (e.g. `/uploads/images/...`) into a
/// full URL. This is required because static files are served from the host
/// root, not under the `/api` prefix used by the mobile API endpoints.
String resolveAssetUrl(String remotePath) {
  final base = Uri.parse(ApiClient.instance.dio.options.baseUrl);
  final path = remotePath.startsWith('/') ? remotePath : '/$remotePath';
  final port = base.hasPort && base.port > 0 ? ':${base.port}' : '';
  return '${base.scheme}://${base.host}$port$path';
}

/// Returns true if [coverUrl] points to a remote asset rather than a local
/// file that has already been downloaded.
bool isRemoteCoverUrl(String? coverUrl) {
  if (coverUrl == null || coverUrl.isEmpty) return false;
  if (coverUrl.startsWith('http')) return true;
  if (coverUrl.startsWith('/uploads/')) return true;
  if (coverUrl.startsWith('uploads/')) return true;
  return false;
}

/// Builds a display URI for a book cover, handling both remote and local files.
String? coverArtUri(LocalBook book) {
  final cover = book.coverUrl;
  if (cover == null || cover.isEmpty) return null;
  if (cover.startsWith('http') || isRemoteCoverUrl(cover)) {
    return resolveAssetUrl(cover);
  }
  return Uri.file(cover).toString();
}

/// Returns a Flutter [ImageProvider] for the given [coverUrl], which can be
/// either a remote server path or a local file path.
ImageProvider? coverImageProvider(String? coverUrl) {
  if (coverUrl == null || coverUrl.isEmpty) return null;
  if (isRemoteCoverUrl(coverUrl)) {
    return NetworkImage(resolveAssetUrl(coverUrl));
  }
  if (coverUrl.startsWith('file:')) {
    return FileImage(File.fromUri(Uri.parse(coverUrl)));
  }
  return FileImage(File(coverUrl));
}
