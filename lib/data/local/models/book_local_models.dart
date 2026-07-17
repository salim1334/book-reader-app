library;
import 'dart:convert';

import 'package:book_store/core/constants/app_enums.dart';

/// Lightweight local data models used by the offline/template schema.
///
/// Docs expect the app to support IMAGE and TEXT books with chapter-based
/// reading progress and offline assets stored on device filesystem.

enum LocalBookType { image, text }

extension LocalBookTypeX on LocalBookType {
  String get dbValue => switch (this) {
    LocalBookType.image => 'IMAGE',
    LocalBookType.text => 'TEXT',
  };

  static LocalBookType fromDb(String raw) => switch (raw.toUpperCase()) {
    'IMAGE' => LocalBookType.image,
    'TEXT' => LocalBookType.text,
    _ => LocalBookType.text,
  };
}

extension SwipeDirectionX on SwipeDirection {
  String get dbValue => switch (this) {
    SwipeDirection.rtl => 'RTL',
    SwipeDirection.ltr => 'LTR',
  };

  static SwipeDirection fromDb(String? raw) => switch (raw?.toUpperCase()) {
    'LTR' => SwipeDirection.ltr,
    _ => SwipeDirection.rtl,
  };

  /// Maps the stored swipe direction to PageView.reverse.
  /// - RTL => true, so pages are laid right-to-left and the user swipes right to advance.
  /// - LTR => false, so pages are laid left-to-right and the user swipes left to advance.
  bool get pageViewReverse => this == SwipeDirection.rtl;
}

class LocalBook {
  const LocalBook({
    required this.id,
    required this.title,
    this.description,
    this.coverUrl,
    required this.type,
    this.swipeDirection = SwipeDirection.rtl,
    required this.version,
  });

  final String id;
  final String title;
  final String? description;
  final String? coverUrl;
  final LocalBookType type;
  final SwipeDirection swipeDirection;
  final int version;

  Map<String, Object?> toDb() => {
    'id': id,
    'title': title,
    'description': description,
    'cover_url': coverUrl,
    'book_type': type.dbValue,
    'swipe_direction': swipeDirection.dbValue,
    'version': version,
  };

  static LocalBook fromDb(Map<String, Object?> row) {
    return LocalBook(
      id: row['id']?.toString() ?? '',
      title: row['title']?.toString() ?? '',
      description: row['description']?.toString(),
      coverUrl: row['cover_url']?.toString(),
      type: LocalBookTypeX.fromDb(row['book_type']?.toString() ?? 'TEXT'),
      swipeDirection: SwipeDirectionX.fromDb(row['swipe_direction']?.toString()),
      version: (row['version'] as num?)?.toInt() ?? 0,
    );
  }
}

class TextSegment {
  const TextSegment({
    required this.content,
    this.startSeconds,
    this.endSeconds,
  });

  final String content;
  final double? startSeconds;
  final double? endSeconds;

  Map<String, Object?> toJson() => {
    'content': content,
    'startSeconds': startSeconds,
    'endSeconds': endSeconds,
  };

  static TextSegment fromJson(Map<String, dynamic> json) {
    double? _toDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    return TextSegment(
      content: json['content']?.toString() ?? '',
      startSeconds: _toDouble(json['startSeconds']),
      endSeconds: _toDouble(json['endSeconds']),
    );
  }
}

class LocalChapter {
  const LocalChapter({
    required this.id,
    required this.bookId,
    required this.title,
    this.description,
    required this.sortOrder,
    this.contentText,
    this.contentSegments,
    required this.version,
    this.isDownloaded = false,
  });

  final String id;
  final String bookId;
  final String title;
  final String? description;
  final int sortOrder;
  final String? contentText;
  final List<TextSegment>? contentSegments;
  final int version;
  final bool isDownloaded;

  Map<String, Object?> toDb() => {
    'id': id,
    'book_id': bookId,
    'title': title,
    'description': description,
    'sort_order': sortOrder,
    'content_text': contentText,
    'content_segments_json': contentSegments == null
        ? null
        : jsonEncode(contentSegments!.map((s) => s.toJson()).toList()),
    'version': version,
    'is_downloaded': isDownloaded ? 1 : 0,
  };

  static LocalChapter fromDb(Map<String, Object?> row) {
    final segmentsJson = row['content_segments_json']?.toString();
    List<TextSegment>? segments;
    if (segmentsJson != null && segmentsJson.isNotEmpty) {
      final list = jsonDecode(segmentsJson) as List<dynamic>;
      segments = list
          .map((e) => TextSegment.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return LocalChapter(
      id: row['id']?.toString() ?? '',
      bookId: row['book_id']?.toString() ?? '',
      title: row['title']?.toString() ?? '',
      description: row['description']?.toString(),
      sortOrder: (row['sort_order'] as num?)?.toInt() ?? 0,
      contentText: row['content_text']?.toString(),
      contentSegments: segments,
      version: (row['version'] as num?)?.toInt() ?? 0,
      isDownloaded: (row['is_downloaded'] as num?)?.toInt() == 1,
    );
  }
}
