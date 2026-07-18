import 'dart:io';

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
