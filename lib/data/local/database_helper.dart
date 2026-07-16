import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:book_store/data/local/tables.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static const int _dbVersion = 6;
  static const String _dbName = 'book_store.db';

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createSettingsTables(db);
    await _createContentTables(db);
    await _createUserAndSyncTables(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Production-friendly migration: create missing tables, add missing columns,
    // and create indexes without dropping existing data.
    for (var version = oldVersion + 1; version <= newVersion; version++) {
      await _migrateToVersion(db, version);
    }
  }

  Future<void> _migrateToVersion(Database db, int version) async {
    if (version == 5) {
      // v5: recreate content tables to ensure id/book_id columns are TEXT
      // (older dev builds created them as INTEGER PRIMARY KEY, which rejects
      // CUID strings from the remote API). Settings tables are preserved.
      await _dropTableIfExists(db, DbTables.downloadedAssets);
      await _dropTableIfExists(db, DbTables.bookmarks);
      await _dropTableIfExists(db, DbTables.readingProgress);
      await _dropTableIfExists(db, DbTables.downloadQueue);
      await _dropTableIfExists(db, DbTables.syncVersions);
      await _dropTableIfExists(db, DbTables.localChapters);
      await _dropTableIfExists(db, DbTables.localBooks);
      await _createContentTables(db);
      await _createUserAndSyncTables(db);
      return;
    }

    if (version == 6) {
      // v6: add chapter description and download tracking for partial content
      await _addColumnIfMissing(
        db,
        DbTables.localChapters,
        'description',
        'TEXT',
      );
      await _addColumnIfMissing(
        db,
        DbTables.localChapters,
        'is_downloaded',
        'INTEGER NOT NULL DEFAULT 0',
      );
      return;
    }

    // All other migration steps are additive and idempotent.
    await _createSettingsTables(db);
    await _createContentTables(db);
    await _createUserAndSyncTables(db);

    if (version >= 4) {
      await _addColumnIfMissing(
        db,
        DbTables.localChapters,
        'content_segments_json',
        'TEXT',
      );
    }
  }

  Future<void> _dropTableIfExists(Database db, String table) async {
    await db.execute('DROP TABLE IF EXISTS $table');
  }

  Future<bool> _hasColumn(Database db, String table, String column) async {
    final rows = await db.rawQuery('PRAGMA table_info($table)');
    return rows.any((r) => r['name'] == column);
  }

  Future<void> _addColumnIfMissing(
    Database db,
    String table,
    String column,
    String type,
  ) async {
    if (!await _hasColumn(db, table, column)) {
      await db.execute('ALTER TABLE $table ADD COLUMN $column $type');
    }
  }

  Future<void> _dropAllTables(Database db) async {
    for (final table in [
      DbTables.syncVersions,
      DbTables.downloadQueue,
      DbTables.readingProgress,
      DbTables.bookmarks,
      DbTables.downloadedAssets,
      DbTables.localChapters,
      DbTables.localBooks,
      DbTables.userSettings,
      DbTables.appSettings,
    ]) {
      await db.execute('DROP TABLE IF EXISTS $table');
    }
  }

  /// System and configuration settings
  Future<void> _createSettingsTables(Database db) async {
    // General app configurations
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DbTables.appSettings} (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    // Author/User specific runtime preferences (e.g., Theme mode)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DbTables.userSettings} (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }

  /// Book content, structures, and asset metadata
  Future<void> _createContentTables(Database db) async {
    // Core book information supporting IMAGE or TEXT types
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DbTables.localBooks} (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        cover_url TEXT,
        book_type TEXT NOT NULL, -- 'IMAGE' or 'TEXT'
        version INTEGER NOT NULL
      )
    ''');

    // Chapter definitions mapping back to parent books
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DbTables.localChapters} (
        id TEXT PRIMARY KEY,
        book_id TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        sort_order INTEGER NOT NULL,
        content_text TEXT, -- Populated if book_type is 'TEXT' and downloaded
        content_segments_json TEXT, -- Optional karaoke timing segments
        version INTEGER NOT NULL,
        is_downloaded INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (book_id) REFERENCES ${DbTables.localBooks}(id) ON DELETE CASCADE
      )
    ''');

    // Filesystem pathways for local page images and audio files
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DbTables.downloadedAssets} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        chapter_id TEXT NOT NULL,
        asset_type TEXT NOT NULL, -- 'IMAGE' or 'AUDIO'
        sort_order INTEGER,       -- Ordering position for IMAGE pages
        file_path TEXT NOT NULL,  -- Absolute or relative path on device storage
        FOREIGN KEY (chapter_id) REFERENCES ${DbTables.localChapters}(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE UNIQUE INDEX IF NOT EXISTS idx_downloadedAssets_unique
        ON ${DbTables.downloadedAssets}(chapter_id, file_path)
    ''');
  }

  /// User activity, bookmarks, queue tracking, and sync structures
  Future<void> _createUserAndSyncTables(Database db) async {
    // Bookmarks tracking per chapter
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DbTables.bookmarks} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        book_id TEXT NOT NULL,
        chapter_id TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (book_id) REFERENCES ${DbTables.localBooks}(id) ON DELETE CASCADE,
        FOREIGN KEY (chapter_id) REFERENCES ${DbTables.localChapters}(id) ON DELETE CASCADE
      )
    ''');

    // Captures reader metrics, scroll layout placements, and audio playback positions
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DbTables.readingProgress} (
        book_id TEXT PRIMARY KEY,
        chapter_id TEXT NOT NULL,
        last_position_ms INTEGER NOT NULL DEFAULT 0, -- Audio track placement tracking
        last_page_index INTEGER NOT NULL DEFAULT 0,  -- Image book page tracking
        updated_at TEXT NOT NULL,
        FOREIGN KEY (book_id) REFERENCES ${DbTables.localBooks}(id) ON DELETE CASCADE,
        FOREIGN KEY (chapter_id) REFERENCES ${DbTables.localChapters}(id) ON DELETE CASCADE
      )
    ''');

    // Handles active/paused sync states and retry metrics for network failures
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DbTables.downloadQueue} (
        chapter_id TEXT PRIMARY KEY,
        book_id TEXT NOT NULL,
        progress REAL NOT NULL DEFAULT 0.0,
        status TEXT NOT NULL, -- 'PENDING', 'DOWNLOADING', 'PAUSED', 'FAILED', 'COMPLETED'
        retry_count INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (book_id) REFERENCES ${DbTables.localBooks}(id) ON DELETE CASCADE,
        FOREIGN KEY (chapter_id) REFERENCES ${DbTables.localChapters}(id) ON DELETE CASCADE
      )
    ''');

    // Granular sync matrix tracking at the chapter/book scope
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DbTables.syncVersions} (
        scope_key TEXT PRIMARY KEY, -- Pattern: 'book_{id}' or 'chapter_{id}'
        local_version INTEGER NOT NULL,
        server_version INTEGER NOT NULL,
        last_sync_timestamp TEXT NOT NULL
      )
    ''');
  }
}
