import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/product.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _db;
  DatabaseHelper._();

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = join(await getDatabasesPath(), 'price_list.db');
    return openDatabase(dbPath, version: 1, onCreate: (db, _) async {
      await db.execute('''
        CREATE TABLE products (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          price REAL NOT NULL,
          category TEXT,
          image_path TEXT,
          created_at TEXT DEFAULT CURRENT_TIMESTAMP
        )
      ''');
    });
  }

  Future<int> insert(Product p) async {
    final db = await database;
    return db.insert('products', p.toMap());
  }

  Future<int> update(Product p) async {
    final db = await database;
    return db.update('products', p.toMap(), where: 'id = ?', whereArgs: [p.id]);
  }

  Future<int> delete(int id) async {
    final db = await database;
    return db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Product>> getAll() async {
    final db = await database;
    final rows = await db.query('products', orderBy: 'created_at DESC');
    return rows.map(Product.fromMap).toList();
  }
}
