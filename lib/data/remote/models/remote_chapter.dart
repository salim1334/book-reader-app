class RemoteChapter {
  const RemoteChapter({
    required this.id,
    required this.bookId,
    required this.title,
    required this.orderIndex,
    required this.version,
    this.pages,
    this.texts,
    this.audios,
  });

  final String id;
  final String bookId;
  final String title;
  final int orderIndex;
  final int version;
  final List<RemotePage>? pages;
  final List<RemoteTextPage>? texts;
  final List<RemoteAudio>? audios;

  factory RemoteChapter.fromJson(Map<String, dynamic> json) {
    return RemoteChapter(
      id: json['id']?.toString() ?? '',
      bookId: json['bookId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      orderIndex: (json['orderIndex'] as num?)?.toInt() ?? 0,
      version: (json['version'] as num?)?.toInt() ?? 0,
      pages: (json['pages'] as List<dynamic>?)
          ?.map((e) => RemotePage.fromJson(e as Map<String, dynamic>))
          .toList(),
      texts: (json['texts'] as List<dynamic>?)
          ?.map((e) => RemoteTextPage.fromJson(e as Map<String, dynamic>))
          .toList(),
      audios: (json['audios'] as List<dynamic>?)
          ?.map((e) => RemoteAudio.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class RemotePage {
  const RemotePage({
    required this.id,
    required this.chapterId,
    required this.imagePath,
    required this.orderIndex,
    required this.version,
    this.audioStartTime,
    this.audioEndTime,
  });

  final String id;
  final String chapterId;
  final String imagePath;
  final int orderIndex;
  final int version;
  final double? audioStartTime;
  final double? audioEndTime;

  factory RemotePage.fromJson(Map<String, dynamic> json) {
    return RemotePage(
      id: json['id']?.toString() ?? '',
      chapterId: json['chapterId']?.toString() ?? '',
      imagePath: json['imagePath']?.toString() ?? '',
      orderIndex: (json['orderIndex'] as num?)?.toInt() ?? 0,
      version: (json['version'] as num?)?.toInt() ?? 0,
      audioStartTime: (json['audioStartTime'] as num?)?.toDouble(),
      audioEndTime: (json['audioEndTime'] as num?)?.toDouble(),
    );
  }
}

class RemoteTextPage {
  const RemoteTextPage({
    required this.id,
    required this.chapterId,
    required this.content,
    required this.orderIndex,
    required this.version,
    this.audioStartTime,
    this.audioEndTime,
  });

  final String id;
  final String chapterId;
  final String content;
  final int orderIndex;
  final int version;
  final double? audioStartTime;
  final double? audioEndTime;

  factory RemoteTextPage.fromJson(Map<String, dynamic> json) {
    return RemoteTextPage(
      id: json['id']?.toString() ?? '',
      chapterId: json['chapterId']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      orderIndex: (json['orderIndex'] as num?)?.toInt() ?? 0,
      version: (json['version'] as num?)?.toInt() ?? 0,
      audioStartTime: (json['audioStartTime'] as num?)?.toDouble(),
      audioEndTime: (json['audioEndTime'] as num?)?.toDouble(),
    );
  }
}

class RemoteAudio {
  const RemoteAudio({
    required this.id,
    required this.chapterId,
    required this.audioPath,
    this.duration,
    required this.version,
  });

  final String id;
  final String chapterId;
  final String audioPath;
  final int? duration;
  final int version;

  factory RemoteAudio.fromJson(Map<String, dynamic> json) {
    return RemoteAudio(
      id: json['id']?.toString() ?? '',
      chapterId: json['chapterId']?.toString() ?? '',
      audioPath: json['audioPath']?.toString() ?? '',
      duration: (json['duration'] as num?)?.toInt(),
      version: (json['version'] as num?)?.toInt() ?? 0,
    );
  }
}
