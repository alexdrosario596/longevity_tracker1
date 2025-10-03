import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/entry.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('entries.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // ✅ Entries table
    await db.execute('''
      CREATE TABLE entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        value TEXT NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');

    // ✅ Onboarding answers table
    await db.execute('''
      CREATE TABLE onboarding_answers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT NOT NULL,
        question TEXT NOT NULL,
        answer TEXT,
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');
  }

  // ============================
  // Entries CRUD
  // ============================

  Future<int> insertEntry(Entry entry) async {
    final db = await instance.database;
    return await db.insert('entries', entry.toMap());
  }

  Future<List<Entry>> getEntries() async {
    final db = await instance.database;
    final result = await db.query('entries', orderBy: "timestamp DESC");
    return result.map((m) => Entry.fromMap(m)).toList();
  }

  Future<int> updateEntry(Entry entry) async {
    final db = await instance.database;
    return await db.update(
      'entries',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<int> deleteEntry(int id) async {
    final db = await instance.database;
    return await db.delete(
      'entries',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ============================
  // Onboarding Answers CRUD
  // ============================

  Future<int> insertOnboardingAnswer(
      String category, String question, String answer) async {
    final db = await instance.database;
    return await db.insert(
      "onboarding_answers",
      {
        "category": category,
        "question": question,
        "answer": answer,
      },
      conflictAlgorithm: ConflictAlgorithm.replace, // overwrite if same question
    );
  }

  Future<List<Map<String, dynamic>>> getOnboardingAnswers(
      String category) async {
    final db = await instance.database;
    return await db.query(
      "onboarding_answers",
      where: "category = ?",
      whereArgs: [category],
    );
  }
}
