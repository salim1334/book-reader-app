import 'package:sqflite/sqflite.dart';
import 'package:book_store/data/local/database_helper.dart';
import 'package:book_store/data/local/tables.dart';

class SettingsDao {
  Future<Database> get _db => DatabaseHelper.instance.database;

  // ─── String ──────────────────────────────────────────
  Future<String?> getString(String key) async {
    final db = await _db;
    final rows = await db.query(
      DbTables.appSettings,
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first['value'] as String?;
  }

  Future<void> setString(String key, String value) async {
    final db = await _db;
    await db.insert(DbTables.appSettings, {
      'key': key,
      'value': value,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // ─── Boolean ──────────────────────────────────────────
  Future<bool> getBool(String key, {bool defaultValue = false}) async {
    final raw = await getString(key);
    if (raw == null) return defaultValue;
    return raw == 'true';
  }

  Future<void> setBool(String key, bool value) async {
    await setString(key, value.toString());
  }

  // ─── Double ──────────────────────────────────────────
  Future<double?> getDouble(String key) async {
    final raw = await getString(key);
    if (raw == null) return null;
    return double.tryParse(raw);
  }

  Future<double> getDoubleOrDefault(String key, double defaultValue) async {
    final value = await getDouble(key);
    return value ?? defaultValue;
  }

  Future<void> setDouble(String key, double value) async {
    await setString(key, value.toString());
  }
}
