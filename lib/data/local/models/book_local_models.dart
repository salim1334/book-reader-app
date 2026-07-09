/// Lightweight local data models used by the offline/template schema.
///
/// Docs expect the app to support IMAGE and TEXT books with chapter-based
/// reading progress and offline assets stored on device filesystem.
library;

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

class LocalBook {
  const LocalBook({
    required this.id,
    required this.title,
    this.description,
    this.coverUrl,
    required this.type,
    required this.version,
  });

  final int id;
  final String title;
  final String? description;
  final String? coverUrl;
  final LocalBookType type;
  final int version;

  Map<String, Object?> toDb() => {
    'id': id,
    'title': title,
    'description': description,
    'cover_url': coverUrl,
    'book_type': type.dbValue,
    'version': version,
  };

  static LocalBook fromDb(Map<String, Object?> row) {
    return LocalBook(
      id: row['id'] as int,
      title: row['title'] as String,
      description: row['description'] as String?,
      coverUrl: row['cover_url'] as String?,
      type: LocalBookTypeX.fromDb(row['book_type'] as String),
      version: row['version'] as int,
    );
  }
}

class LocalChapter {
  const LocalChapter({
    required this.id,
    required this.bookId,
    required this.title,
    required this.sortOrder,
    this.contentText,
    required this.version,
  });

  final int id;
  final int bookId;
  final String title;
  final int sortOrder;
  final String? contentText;
  final int version;

  Map<String, Object?> toDb() => {
    'id': id,
    'book_id': bookId,
    'title': title,
    'sort_order': sortOrder,
    'content_text': contentText,
    'version': version,
  };

  static LocalChapter fromDb(Map<String, Object?> row) {
    return LocalChapter(
      id: row['id'] as int,
      bookId: row['book_id'] as int,
      title: row['title'] as String,
      sortOrder: row['sort_order'] as int,
      contentText: row['content_text'] as String?,
      version: row['version'] as int,
    );
  }
}
