import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:book_store/data/local/tables.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static const int _dbVersion = 1;
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
    // Handle migrations here if versioning changes in future releases
  }

  /// System and configuration settings
  Future<void> _createSettingsTables(Database db) async {
    // General app configurations
    await db.execute('''
      CREATE TABLE ${DbTables.appSettings} (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    // Author/User specific runtime preferences (e.g., Theme mode)
    await db.execute('''
      CREATE TABLE ${DbTables.userSettings} (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }

  /// Book content, structures, and asset metadata
  Future<void> _createContentTables(Database db) async {
    // Core book information supporting IMAGE or TEXT types
    await db.execute('''
      CREATE TABLE ${DbTables.localBooks} (
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        cover_url TEXT,
        book_type TEXT NOT NULL, -- 'IMAGE' or 'TEXT'
        version INTEGER NOT NULL
      )
    ''');

    // Chapter definitions mapping back to parent books
    await db.execute('''
      CREATE TABLE ${DbTables.localChapters} (
        id INTEGER PRIMARY KEY,
        book_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        sort_order INTEGER NOT NULL,
        content_text TEXT, -- Populated if book_type is 'TEXT'
        version INTEGER NOT NULL,
        FOREIGN KEY (book_id) REFERENCES ${DbTables.localBooks}(id) ON DELETE CASCADE
      )
    ''');

    // Filesystem pathways for local page images and audio files
    await db.execute('''
      CREATE TABLE ${DbTables.downloadedAssets} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        chapter_id INTEGER NOT NULL,
        asset_type TEXT NOT NULL, -- 'IMAGE' or 'AUDIO'
        file_path TEXT NOT NULL,  -- Absolute or relative path on device storage
        FOREIGN KEY (chapter_id) REFERENCES ${DbTables.localChapters}(id) ON DELETE CASCADE
      )
    ''');
  }

  /// User activity, bookmarks, queue tracking, and sync structures
  Future<void> _createUserAndSyncTables(Database db) async {
    // Bookmarks tracking per chapter
    await db.execute('''
      CREATE TABLE ${DbTables.bookmarks} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        book_id INTEGER NOT NULL,
        chapter_id INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (book_id) REFERENCES ${DbTables.localBooks}(id) ON DELETE CASCADE,
        FOREIGN KEY (chapter_id) REFERENCES ${DbTables.localChapters}(id) ON DELETE CASCADE
      )
    ''');

    // Captures reader metrics, scroll layout placements, and audio playback positions
    await db.execute('''
      CREATE TABLE ${DbTables.readingProgress} (
        book_id INTEGER PRIMARY KEY,
        chapter_id INTEGER NOT NULL,
        last_position_ms INTEGER NOT NULL DEFAULT 0, -- Audio track placement tracking
        last_page_index INTEGER NOT NULL DEFAULT 0,  -- Image book page tracking
        updated_at TEXT NOT NULL,
        FOREIGN KEY (book_id) REFERENCES ${DbTables.localBooks}(id) ON DELETE CASCADE,
        FOREIGN KEY (chapter_id) REFERENCES ${DbTables.localChapters}(id) ON DELETE CASCADE
      )
    ''');

    // Handles active/paused sync states and retry metrics for network failures
    await db.execute('''
      CREATE TABLE ${DbTables.downloadQueue} (
        chapter_id INTEGER PRIMARY KEY,
        book_id INTEGER NOT NULL,
        progress REAL NOT NULL DEFAULT 0.0,
        status TEXT NOT NULL, -- 'PENDING', 'DOWNLOADING', 'PAUSED', 'FAILED', 'COMPLETED'
        retry_count INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (book_id) REFERENCES ${DbTables.localBooks}(id) ON DELETE CASCADE,
        FOREIGN KEY (chapter_id) REFERENCES ${DbTables.localChapters}(id) ON DELETE CASCADE
      )
    ''');

    // Granular sync matrix tracking at the chapter/book scope
    await db.execute('''
      CREATE TABLE ${DbTables.syncVersions} (
        scope_key TEXT PRIMARY KEY, -- Pattern: 'book_{id}' or 'chapter_{id}'
        local_version INTEGER NOT NULL,
        server_version INTEGER NOT NULL,
        last_sync_timestamp TEXT NOT NULL
      )
    ''');
  }
}
