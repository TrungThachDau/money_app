// filepath: d:\Code\money_app\lib\features\category\service.dart
import 'package:sqflite/sqflite.dart';

import '../../app/db_helper.dart';

class CategoryService {
  final DBHelper _dbHelper = DBHelper();

  Future<List<Map<String, dynamic>>> getCategories() async {
    final Database db = await _dbHelper.database;
    // Order by name case-insensitive
    return await db.query('Category', orderBy: 'Name COLLATE NOCASE');
  }

  /// Validate category name
  bool isValidName(String name) {
    return name.trim().isNotEmpty;
  }

  /// Add new category with validation
  /// Returns the inserted id if successful, -1 if validation fails
  Future<int> addCategory(String name) async {
    final trimmedName = name.trim();
    if (!isValidName(trimmedName)) {
      return -1;
    }

    final Database db = await _dbHelper.database;
    return await db.insert('Category', {'Name': trimmedName});
  }

  /// Update category with validation
  /// Returns the number of rows affected, -1 if validation fails
  Future<int> updateCategory(int id, String name) async {
    final trimmedName = name.trim();
    if (!isValidName(trimmedName)) {
      return -1;
    }

    final Database db = await _dbHelper.database;
    return await db.update(
      'Category',
      {'Name': trimmedName},
      where: 'Id = ?',
      whereArgs: [id],
    );
  }

  /// Delete category by id
  Future<int> deleteCategory(int id) async {
    final Database db = await _dbHelper.database;
    return await db.delete(
      'Category',
      where: 'Id = ?',
      whereArgs: [id],
    );
  }
}

