import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Quản lý SQLite cục bộ. Giữ nguyên expense.db từ buổi 5.
class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  Future<Database> get database async {
    return _database ??= await _initDatabase();
  }

  Future<Database> _initDatabase() async {
    final directory = await getDatabasesPath();
    final dbPath = join(directory, 'expense.db');
    return openDatabase(
      dbPath,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            category TEXT NOT NULL,
            date TEXT NOT NULL,
            amount REAL NOT NULL,
            type TEXT NOT NULL,
            note TEXT NOT NULL DEFAULT ''
          )
        ''');
        await _createSettingsTable(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Không xóa bảng/giao dịch cũ khi nâng từ buổi 5 lên buổi 6.
          await db.execute(
            "ALTER TABLE transactions ADD COLUMN note TEXT NOT NULL DEFAULT ''",
          );
          await _createSettingsTable(db);
        }
      },
    );
  }

  Future<void> _createSettingsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS app_settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertTransaction(Map<String, Object?> data) async {
    final db = await database;
    return db.insert('transactions', data);
  }

  Future<List<Map<String, Object?>>> getTransactions() async {
    final db = await database;
    return db.query('transactions', orderBy: 'date DESC, id DESC');
  }

  Future<int> updateTransaction(int id, Map<String, Object?> data) async {
    final db = await database;
    return db.update(
      'transactions', data, where: 'id = ?', whereArgs: [id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<String?> getSetting(String key) async {
    final db = await database;
    final rows = await db.query(
      'app_settings', columns: ['value'], where: 'key = ?',
      whereArgs: [key], limit: 1,
    );
    return rows.isEmpty ? null : rows.first['value'] as String;
  }

  Future<void> setSetting(String key, String value) async {
    final db = await database;
    await db.insert(
      'app_settings', {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
