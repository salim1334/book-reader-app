class RemoteBook {
  const RemoteBook({
    required this.id,
    required this.title,
    this.description,
    this.coverImage,
    required this.type,
    this.swipeDirection = 'RTL',
    required this.version,
    required this.author,
    this.chapters = const [],
    this.chaptersCount,
    this.status,
    this.published,
    this.unpublishChange,
  });

  final String id;
  final String title;
  final String? description;
  final String? coverImage;
  final String type; // 'IMAGE' or 'TEXT'
  final String swipeDirection; // 'RTL' or 'LTR'
  final int version;
  final RemoteAuthor author;
  final List<RemoteChapterSummary> chapters;
  final int? chaptersCount;
  final String? status;
  final bool? published;
  final bool? unpublishChange;

  bool get isPublished {
    if (published == false) return false;
    if (unpublishChange == true) return false;
    if (status != null) {
      final s = status!.toLowerCase();
      if (s == 'published') return true;
      if (s == 'unpublished' ||
          s == 'unpublish_change' ||
          s == 'unpublish-change' ||
          s == 'draft' ||
          s == 'pending' ||
          s == 'false') {
        return false;
      }
    }
    return true;
  }

  factory RemoteBook.fromJson(Map<String, dynamic> json) {
    final counts = json['_count'] as Map<String, dynamic>?;
    final parsedChapters = (json['chapters'] as List<dynamic>?)
            ?.map((e) => RemoteChapterSummary.fromJson(e as Map<String, dynamic>))
            .toList() ??
        const [];
    return RemoteBook(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      coverImage: json['coverImage']?.toString(),
      type: json['type']?.toString() ?? 'TEXT',
      swipeDirection: json['swipeDirection']?.toString() ?? 'RTL',
      version: (json['version'] as num?)?.toInt() ?? 0,
      author: RemoteAuthor.fromJson((json['author'] as Map<String, dynamic>?) ?? {}),
      chapters: parsedChapters,
      chaptersCount: (counts?['chapters'] as num?)?.toInt() ??
          parsedChapters.length,
      status: json['status']?.toString(),
      published: json['published'] as bool? ?? json['isPublished'] as bool?,
      unpublishChange: json['unpublish_change'] as bool? ??
          json['unpublishChange'] as bool?,
    );
  }
}

class RemoteAuthor {
  const RemoteAuthor({required this.id, required this.name});

  final String id;
  final String name;

  factory RemoteAuthor.fromJson(Map<String, dynamic> json) {
    return RemoteAuthor(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }
}

class RemoteChapterSummary {
  const RemoteChapterSummary({
    required this.id,
    required this.title,
    this.description,
    required this.orderIndex,
    required this.version,
    this.pagesCount,
    this.textsCount,
    this.audiosCount,
  });

  final String id;
  final String title;
  final String? description;
  final int orderIndex;
  final int version;
  final int? pagesCount;
  final int? textsCount;
  final int? audiosCount;

  factory RemoteChapterSummary.fromJson(Map<String, dynamic> json) {
    final counts = json['_count'] as Map<String, dynamic>?;
    return RemoteChapterSummary(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      orderIndex: (json['orderIndex'] as num?)?.toInt() ?? 0,
      version: (json['version'] as num?)?.toInt() ?? 0,
      pagesCount: (counts?['pages'] as num?)?.toInt(),
      textsCount: (counts?['texts'] as num?)?.toInt(),
      audiosCount: (counts?['audios'] as num?)?.toInt(),
    );
  }
}
