import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance =
  DatabaseHelper._internal();

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();

    final path = join(
      databasePath,
      'expense.db',
    );

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // INSERT - Thêm giao dịch
  Future<int> insertTransaction(
      Map<String, Object?> data,
      ) async {
    final db = await database;

    return await db.insert(
      'transactions',
      data,
    );
  }

  // SELECT - Lấy danh sách giao dịch
  Future<List<Map<String, Object?>>> getTransactions() async {
    final db = await database;

    return await db.query(
      'transactions',
      orderBy: 'date DESC, id DESC',
    );
  }

  // DELETE - Xóa giao dịch trong SQLite
  Future<int> deleteTransaction(int id) async {
    final db = await database;

    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // UPDATE - Sửa giao dịch trong SQLite
  Future<int> updateTransaction(
      int id,
      Map<String, Object?> data,
      ) async {
    final db = await database;

    return await db.update(
      'transactions',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }




  Future<void> _onCreate(
      Database db,
      int version,
      ) async {
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        category TEXT NOT NULL,
        date TEXT NOT NULL,
        amount REAL NOT NULL,
        type TEXT NOT NULL
      )
    ''');
  }
}