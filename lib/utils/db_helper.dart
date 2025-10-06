import 'package:random_cat_facts/model/cat_fact_model.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    return await openDatabase(
      'cat_facts.db',
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE cat_facts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fact TEXT NOT NULL,
        imageUrl TEXT NOT NULL,
        savedAt TEXT NOT NULL
      )
    ''');
  }

  Future<int> saveCatFact(CatFactModel catFact) async {
    Database db = await database;
    return await db.insert('cat_facts', catFact.toMap());
  }

  Future<List<CatFactModel>> getSavedCatFacts() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('cat_facts', orderBy: 'savedAt DESC');
    return List.generate(maps.length, (i) {
      return CatFactModel.fromMap(maps[i]);
    });
  }

  Future<int> deleteCatFact(int id) async {
    Database db = await database;
    return await db.delete(
      'cat_facts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> closeDatabase() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
    }
  }

  // Add this to your database helper class
  Future<CatFactModel?> getCatFactByText(String factText) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'cat_facts',
      where: 'fact = ?',
      whereArgs: [factText],
    );

    if (maps.isEmpty) {
      return null;
    }

    return CatFactModel.fromMap(maps.first);
  }
}
