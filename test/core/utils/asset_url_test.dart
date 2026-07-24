import 'package:book_store/core/utils/asset_url.dart';
import 'package:book_store/data/local/models/book_local_models.dart';
import 'package:book_store/data/remote/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('asset_url', () {
    setUp(() {
      ApiClient.instance.dio.options.baseUrl = 'https://cdn.example.com/';
    });

    test('resolveAssetUrl appends remote path to base URL', () {
      expect(
        resolveAssetUrl('/uploads/images/book.jpg'),
        'https://cdn.example.com/uploads/images/book.jpg',
      );
    });

    test('resolveAssetUrl adds leading slash when missing', () {
      expect(
        resolveAssetUrl('uploads/images/book.jpg'),
        'https://cdn.example.com/uploads/images/book.jpg',
      );
    });

    test('isRemoteCoverUrl returns true for http paths', () {
      expect(isRemoteCoverUrl('https://example.com/cover.jpg'), true);
    });

    test('isRemoteCoverUrl returns true for /uploads/ paths', () {
      expect(isRemoteCoverUrl('/uploads/cover.jpg'), true);
    });

    test('isRemoteCoverUrl returns true for uploads/ paths', () {
      expect(isRemoteCoverUrl('uploads/cover.jpg'), true);
    });

    test('isRemoteCoverUrl returns false for local paths', () {
      expect(isRemoteCoverUrl('/data/cover.jpg'), false);
      expect(isRemoteCoverUrl(null), false);
      expect(isRemoteCoverUrl(''), false);
    });

    test('coverArtUri resolves remote and local covers', () {
      final remoteBook = LocalBook(
        id: 'b1',
        title: 'Remote',
        coverUrl: '/uploads/cover.jpg',
        type: LocalBookType.text,
        version: 1,
      );
      expect(
        coverArtUri(remoteBook),
        'https://cdn.example.com/uploads/cover.jpg',
      );

      final localBook = LocalBook(
        id: 'b2',
        title: 'Local',
        coverUrl: '/tmp/cover.jpg',
        type: LocalBookType.text,
        version: 1,
      );
      expect(coverArtUri(localBook), 'file:///tmp/cover.jpg');
    });

    test('coverImageProvider returns NetworkImage for remote covers', () {
      final provider = coverImageProvider('/uploads/cover.jpg');
      expect(provider, isA<NetworkImage>());
    });

    test('coverImageProvider returns FileImage for local covers', () {
      final provider = coverImageProvider('/tmp/cover.jpg');
      expect(provider, isA<FileImage>());
    });

    test('coverImageProvider returns null for empty covers', () {
      expect(coverImageProvider(null), null);
      expect(coverImageProvider(''), null);
    });
  });
}
