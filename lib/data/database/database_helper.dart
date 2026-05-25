import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;
  static const _dbName = 'lingxitianji.db';
  static const _dbVersion = 1;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _init();
    return _database!;
  }

  static Future<Database> _init() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE history (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        create_time INTEGER NOT NULL,
        summary TEXT DEFAULT '',
        json_data TEXT
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_history_type ON history(type)
    ''');

    await db.execute('''
      CREATE INDEX idx_history_time ON history(create_time DESC)
    ''');
  }

  static Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
