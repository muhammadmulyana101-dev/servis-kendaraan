import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/servis.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();
  DatabaseHelper._();
  static Database? _db;

  Future<Database> get db async => _db ??= await _init();

  Future<Database> _init() async {
    final path = join(await getDatabasesPath(), 'servis.db');
    return openDatabase(path, version: 1, onCreate: (db, v) async {
      await db.execute('''
        CREATE TABLE users(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nama TEXT NOT NULL,
          email TEXT UNIQUE NOT NULL,
          password TEXT NOT NULL)''');
      await db.execute('''
        CREATE TABLE servis(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          judul TEXT NOT NULL,
          tanggal TEXT NOT NULL,
          biaya INTEGER NOT NULL,
          catatan TEXT)''');
    });
  }

  Future<int> insertServis(Servis s) async =>
      (await db).insert('servis', s.toMap());

  Future<List<Servis>> getServis(int userId) async {
    final rows = await (await db).query('servis',
        where: 'user_id = ?', whereArgs: [userId], orderBy: 'tanggal DESC');
    return rows.map(Servis.fromMap).toList();
  }

  Future<int> updateServis(Servis s) async => (await db)
      .update('servis', s.toMap(), where: 'id = ?', whereArgs: [s.id]);

  Future<int> deleteServis(int id) async =>
      (await db).delete('servis', where: 'id = ?', whereArgs: [id]);
}