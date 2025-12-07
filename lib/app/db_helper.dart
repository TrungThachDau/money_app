import 'package:sqflite/sqflite.dart';
import "package:path/path.dart";

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'expense_manager.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      // onUpgrade: _onUpgrade, // sau này đổi version để migrate
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE Category (
        Id INTEGER PRIMARY KEY AUTOINCREMENT,
        Name TEXT NOT NULL,
        Icon TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE Wallet (
        Id INTEGER PRIMARY KEY AUTOINCREMENT,
        Name TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE Transactions (
        Id INTEGER PRIMARY KEY AUTOINCREMENT,
        Type TEXT NOT NULL,
        Amount REAL NOT NULL,
        Wallet INTEGER NOT NULL,
        Category INTEGER,
        Note TEXT,
        DateTime TEXT NOT NULL,
        FOREIGN KEY (Wallet) REFERENCES Wallet (Id),
        FOREIGN KEY (Category) REFERENCES Category (Id)
      );
    ''');

    await db.execute('''
      CREATE TABLE Budget (
        Id INTEGER PRIMARY KEY AUTOINCREMENT,
        Category INTEGER NOT NULL,
        Amount REAL NOT NULL,
        DateTime TEXT NOT NULL,
        FOREIGN KEY (Category) REFERENCES Category (Id)
      );
    ''');
    await db.insert('Category', {'Name': 'Ăn uống', 'Icon': 'fastfood'});
    await db.insert('Category', {'Name': 'Đi lại', 'Icon': 'directions_bus'});
    await db.insert('Category', {'Name': 'Giải trí', 'Icon': 'sports_esports'});
    await db.insert('Category', {'Name': 'Mua sắm', 'Icon': 'shopping_bag'});
    await db.insert('Category', {'Name': 'Lương', 'Icon': 'attach_money'});

    // Wallet
    await db.insert('Wallet', {'Name': 'Tiền mặt'});
    await db.insert('Wallet', {'Name': 'Thẻ tín dụng'});
    await db.insert('Wallet', {'Name': 'Ví điện tử'});
  }

  Future<int> insertTransaction({
    required String type,
    required double amount,
    required int walletId,
    required int categoryId,
    String? note,
    required DateTime dateTime,
  }) async {
    final db = await database;
    return await db.insert('Transactions', {
      'Type': type,
      'Amount': amount,
      'Wallet': walletId,
      'Category': categoryId,
      'Note': note,
      'DateTime': dateTime.toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    final db = await database;
    return await db.query('Category');
  }

  Future<List<Map<String, dynamic>>> getExpenseByCategoryInMonth(
    DateTime month,
  ) async {
    final db = await database;
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
    return await db.rawQuery(
      '''
      SELECT c.Id, c.Name, c.Icon, IFNULL(SUM(t.Amount), 0) as Total
      FROM Category c
      LEFT JOIN Transactions t ON t.Category = c.Id AND t.Type = 'expense' AND t.DateTime >= ? AND t.DateTime <= ?
      GROUP BY c.Id, c.Name, c.Icon
      ORDER BY Total DESC
    ''',
      [firstDay.toIso8601String(), lastDay.toIso8601String()],
    );
  }

  Future<double> getTotalExpenseInMonth(DateTime month) async {
    final db = await database;
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
    final result = await db.rawQuery(
      '''
      SELECT IFNULL(SUM(Amount), 0) as Total
      FROM Transactions
      WHERE Type = 'expense' AND DateTime >= ? AND DateTime <= ?
    ''',
      [firstDay.toIso8601String(), lastDay.toIso8601String()],
    );
    return (result.first['Total'] as num?)?.toDouble() ?? 0.0;
  }
}
