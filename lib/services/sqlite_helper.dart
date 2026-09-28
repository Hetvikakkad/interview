import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;
import '../models/employee_model.dart';

class SqliteHelper {
  static const String tableName = 'items';

  static Future<void> _createTables(sql.Database database) async {
    await database.execute('''
      CREATE TABLE $tableName(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        name TEXT NOT NULL,
        number TEXT,
        email TEXT,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    ''');
  }

  static Future<sql.Database> _db() async {
    return sql.openDatabase(
      'employee.db',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await _createTables(database);
      },
    );
  }

  // Create new employee
  static Future<int> createItem(Employee employee) async {
    final db = await _db();
    return db.insert(
      tableName,
      employee.toMap(),
      conflictAlgorithm: sql.ConflictAlgorithm.replace,
    );
  }

  // Read all employees
  static Future<List<Employee>> getItems() async {
    final db = await _db();
    final List<Map<String, dynamic>> maps =
        await db.query(tableName, orderBy: 'id DESC');
    return maps.map((map) => Employee.fromMap(map)).toList();
  }

  // Update employee by id
  static Future<int> updateItem(Employee employee) async {
    if (employee.id == null) return 0;
    final db = await _db();
    final data = {
      ...employee.toMap(),
      'createdAt': DateTime.now().toIso8601String(),
    };
    return db.update(
      tableName,
      data,
      where: 'id = ?',
      whereArgs: [employee.id],
    );
  }

  // Delete employee by id
  static Future<int> deleteItem(int id) async {
    final db = await _db();
    try {
      return await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
    } catch (err) {
      debugPrint('Error deleting employee: $err');
      return 0;
    }
  }
}
