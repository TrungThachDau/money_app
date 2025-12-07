import 'package:sqflite/sqflite.dart';
import '../../app/db_helper.dart';

/// Service quản lý CRUD cho bảng Wallet
class WalletService {
  final DBHelper _dbHelper = DBHelper();

  /// Lấy danh sách tất cả ví, sắp xếp theo tên
  Future<List<Map<String, dynamic>>> getWallets() async {
    final Database db = await _dbHelper.database;
    return await db.query('Wallet', orderBy: 'Name COLLATE NOCASE');
  }

  /// Thêm ví mới, trả về ID của ví vừa thêm
  Future<int> addWallet(String name) async {
    final Database db = await _dbHelper.database;
    return await db.insert('Wallet', {'Name': name});
  }

  /// Cập nhật tên ví
  Future<int> updateWallet(int id, String name) async {
    final Database db = await _dbHelper.database;
    return await db.update(
      'Wallet',
      {'Name': name},
      where: 'Id = ?',
      whereArgs: [id],
    );
  }

  /// Xóa ví theo ID
  Future<int> deleteWallet(int id) async {
    final Database db = await _dbHelper.database;
    return await db.delete(
      'Wallet',
      where: 'Id = ?',
      whereArgs: [id],
    );
  }
}
