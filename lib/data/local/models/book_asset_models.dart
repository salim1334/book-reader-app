enum LocalAssetType { image, audio }

extension LocalAssetTypeX on LocalAssetType {
  String get dbValue => switch (this) {
    LocalAssetType.image => 'IMAGE',
    LocalAssetType.audio => 'AUDIO',
  };

  static LocalAssetType fromDb(String raw) => switch (raw.toUpperCase()) {
    'AUDIO' => LocalAssetType.audio,
    _ => LocalAssetType.image,
  };
}

class DownloadedAsset {
  const DownloadedAsset({
    required this.id,
    required this.chapterId,
    required this.type,
    required this.filePath,
  });

  final int id;
  final int chapterId;
  final LocalAssetType type;
  final String filePath;

  static DownloadedAsset fromDb(Map<String, Object?> row) {
    return DownloadedAsset(
      id: row['id'] as int,
      chapterId: row['chapter_id'] as int,
      type: LocalAssetTypeX.fromDb(row['asset_type'] as String),
      filePath: row['file_path'] as String,
    );
  }
}
