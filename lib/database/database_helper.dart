import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  // Initialize and get the database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Database initialization
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'image_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        db.execute('''
          CREATE TABLE images (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            imagePath TEXT NOT NULL
          )
        ''');
      },
    );
  }

  // Insert an image path into the database
  Future<void> insertImage(String imagePath) async {
    final db = await database;
    await db.insert(
      'images',
      {'imagePath': imagePath},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Fetch all saved image paths from the database
  Future<List<String>> getImages() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('images');

    // Extract and return the image paths from the database
    return List<String>.from(maps.map((map) => map['imagePath']));
  }

  // Delete an image by its path
  Future<void> deleteImage(String imagePath) async {
    final db = await database;
    await db.delete(
      'images',
      where: 'imagePath = ?',
      whereArgs: [imagePath],
    );
  }
}
