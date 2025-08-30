
import 'package:flutter/foundation.dart';import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:restoreko/models/restaurant.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  static const String tableFavorites = 'favorites';
  static const String columnId = 'id';
  static const String columnName = 'name';
  static const String columnDescription = 'description';
  static const String columnPictureId = 'pictureId';
  static const String columnCity = 'city';
  static const String columnRating = 'rating';

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'restoreko.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableFavorites (
        $columnId TEXT PRIMARY KEY,
        $columnName TEXT NOT NULL,
        $columnDescription TEXT,
        $columnPictureId TEXT,
        $columnCity TEXT,
        $columnRating REAL
      )
    ''');
  }

  Future<void> insertFavorite(Restaurant restaurant) async {
    final db = await database;
    await db.insert(
      tableFavorites,
      restaurant.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getFavorites() async {
    try {
      final db = await database;
      return await db.query(tableFavorites);
    } catch (e) {
      debugPrint('Error getting favorites: $e');
      return [];
    }
  }

  Future<Restaurant?> getFavorite(String id) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        tableFavorites,
        where: '$columnId = ?',
        whereArgs: [id],
      );
      return maps.isNotEmpty ? Restaurant.fromJson(maps.first) : null;
    } catch (e) {
      debugPrint('Error getting favorite: $e');
      return null;
    }
  }

  Future<int> deleteFavorite(String id) async {
    final db = await database;
    return await db.delete(
      tableFavorites,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  Future<bool> isFavorite(String id) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        tableFavorites,
        where: '$columnId = ?',
        whereArgs: [id],
        limit: 1,
      );
      return maps.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking if favorite: $e');
      return false;
    }
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
