import 'dart:convert';
import 'dart:io';

import 'package:book_store/core/constants/app_enums.dart';
import 'package:book_store/data/local/daos/book_dao.dart';
import 'package:book_store/data/local/daos/settings_dao.dart';
import 'package:book_store/data/local/models/book_local_models.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

/// Seeds one or more books that are shipped inside the app bundle
/// (assets/data/bundled_books.json + assets/data/bundled_books/<bookId>/...)
/// so a user has at least one full book available immediately after install,
/// with zero network required.
///
/// IMPORTANT: give each bundled book the SAME id/chapter ids it has on your
/// server (book_store_admin). That way this is indistinguishable from a
/// normal downloaded book to the rest of the app: SyncManager.syncCatalog()
/// will just update its title/order over time, and updateBook() will pull
/// any real content updates later. No special-casing needed anywhere else.
class BundledContentSeeder {
  /// Populated after seeding so other code can identify bundled books.
  static final Set<String> bundledBookIds = {};
  BundledContentSeeder(this._dao, {SettingsDao? settingsDao})
      : _settingsDao = settingsDao ?? SettingsDao();

  final BookDao _dao;
  final SettingsDao _settingsDao;

  /// Bump this if you ever change the bundled manifest shape/content and
  /// want it to re-seed (e.g. adding a second free book) on existing installs.
  static const String _flagKey = 'bundled_content_seeded_v1';
  static const String _manifestAssetPath = 'assets/data/bundled_books.json';

  Future<void> seedIfNeeded() async {
    final manifestRaw = await rootBundle.loadString(_manifestAssetPath);
    final manifest = jsonDecode(manifestRaw) as Map<String, dynamic>;
    final books = (manifest['books'] as List<dynamic>? ?? []);
    bundledBookIds.addAll(
      books.map((b) => (b as Map<String, dynamic>)['id'] as String),
    );

    final alreadySeeded = await _settingsDao.getBool(_flagKey);
    if (alreadySeeded) return;

    try {
      for (final raw in books) {
        await _seedBook(raw as Map<String, dynamic>);
      }

      // Only mark as done on success, so a bad/missing manifest doesn't
      // permanently skip seeding.
      // debugPrint('BundledContentSeeder: ✅✅✅✅✅✅✅ seeded ${books.length} book(s)');
      await _settingsDao.setBool(_flagKey, true);
    } catch (e, st) {
      debugPrint('BundledContentSeeder: ❌❌❌❌❌❌❌❌ failed to seed bundled content: $e\n$st');
    }
  }

  Future<void> _seedBook(Map<String, dynamic> raw) async {
    final bookId = raw['id'] as String;
    final bookType = LocalBookTypeX.fromDb(raw['bookType'] as String? ?? 'TEXT');
    final swipeDirection = SwipeDirectionX.fromDb(raw['swipeDirection'] as String?);

    String? coverPath;
    final coverAsset = raw['coverAsset'] as String?;
    if (coverAsset != null && coverAsset.isNotEmpty) {
      coverPath = await _copyAsset(
        coverAsset,
        assetType: 'images',
        bookId: bookId,
        chapterId: 'cover',
      );
    }

    final chaptersRaw = (raw['chapters'] as List<dynamic>? ?? []);
    final chapters = <LocalChapter>[];
    for (final chRaw in chaptersRaw) {
      final ch = chRaw as Map<String, dynamic>;
      chapters.add(
        LocalChapter(
          id: ch['id'] as String,
          bookId: bookId,
          title: ch['title'] as String,
          description: ch['description'] as String?,
          sortOrder: (ch['orderIndex'] as num?)?.toInt() ??
              (ch['sortOrder'] as num?)?.toInt() ??
              0,
          contentText: ch['contentText'] as String?,
          version: (ch['version'] as num?)?.toInt() ?? 1,
          isDownloaded: true,
        ),
      );
    }

    await _dao.insertBooksAndChapters(
      book: LocalBook(
        id: bookId,
        title: raw['title'] as String,
        description: raw['description'] as String?,
        coverUrl: coverPath,
        type: bookType,
        swipeDirection: swipeDirection,
        version: (raw['version'] as num?)?.toInt() ?? 1,
      ),
      chapters: chapters,
    );

    // Copy any IMAGE pages / AUDIO files for IMAGE-type chapters into the
    // exact same folder layout DownloadManager uses, so the reader screens
    // don't need to know this content came from assets instead of network.
    for (final chRaw in chaptersRaw) {
      final ch = chRaw as Map<String, dynamic>;
      final chapterId = ch['id'] as String;

      final pages = ch['pages'] as List<dynamic>? ?? [];
      for (final pageRaw in pages) {
        final page = pageRaw as Map<String, dynamic>;
        final pageSortOrder =
            (page['orderIndex'] as num?)?.toInt() ??
            (page['sortOrder'] as num?)?.toInt();
        final pageAudioStart = (page['audioStartTime'] as num?)?.toDouble();
        final pageAudioEnd = (page['audioEndTime'] as num?)?.toDouble();

        final localPath = await _copyAsset(
          (page['imagePath'] as String? ?? page['imageAsset'] as String? ?? ''),
          assetType: 'images',
          bookId: bookId,
          chapterId: chapterId,
        );
        await _dao.insertDownloadedAsset(
          chapterId: chapterId,
          assetType: 'IMAGE',
          filePath: localPath,
          sortOrder: pageSortOrder,
          audioStartTime: pageAudioStart,
          audioEndTime: pageAudioEnd,
        );

        final pageAudioAsset =
            page['audioPath'] as String? ?? page['audioAsset'] as String?;
        if (pageAudioAsset != null && pageAudioAsset.isNotEmpty) {
          final audioLocalPath = await _copyAsset(
            pageAudioAsset,
            assetType: 'audio',
            bookId: bookId,
            chapterId: chapterId,
          );
          await _dao.insertDownloadedAsset(
            chapterId: chapterId,
            assetType: 'AUDIO',
            filePath: audioLocalPath,
            sortOrder: pageSortOrder,
            audioStartTime: pageAudioStart,
            audioEndTime: pageAudioEnd,
          );
        }
      }

      final audios = ch['audio'] as List<dynamic>? ?? [];
      for (final audioRaw in audios) {
        final audio = audioRaw as Map<String, dynamic>;
        final localPath = await _copyAsset(
          (audio['audioPath'] as String? ?? audio['audioAsset'] as String? ?? ''),
          assetType: 'audio',
          bookId: bookId,
          chapterId: chapterId,
        );
        await _dao.insertDownloadedAsset(
          chapterId: chapterId,
          assetType: 'AUDIO',
          filePath: localPath,
        );
      }
    }
  }

  /// Copies a bundled asset into
  /// `<app documents dir>/downloads/<assetType>/<bookId>/<chapterId>/<fileName>`
  /// — identical to what DownloadManager.downloadAsset produces for a real
  /// network download, so every existing reader/download code path works
  /// unmodified.
  Future<String> _copyAsset(
    String assetPath, {
    required String assetType,
    required String bookId,
    required String chapterId,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final folder = Directory(
      '${dir.path}/downloads/$assetType/$bookId/$chapterId',
    );
    if (!folder.existsSync()) {
      await folder.create(recursive: true);
    }
    final fileName = assetPath.split('/').last;
    final localPath = '${folder.path}/$fileName';
    final file = File(localPath);

    if (!file.existsSync()) {
      final data = await rootBundle.load(assetPath);
      await file.writeAsBytes(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      );
    }

    return localPath;
  }
}
