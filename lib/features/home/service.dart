import 'package:intl/intl.dart';
import '../../../app/db_helper.dart';

class HomeService {
  final DBHelper _dbHelper = DBHelper();

  // Lấy danh mục từ database
  Future<List<Map<String, dynamic>>> loadCategories() async {
    final db = await _dbHelper.database;
    return await db.query('Category');
  }

  // Lấy danh sách ví từ database
  Future<List<Map<String, dynamic>>> loadWallets() async {
    final db = await _dbHelper.database;
    return await db.query('Wallet');
  }

  // Lấy ví mặc định là "Tiền mặt"
  Map<String, dynamic>? getDefaultWallet(List<Map<String, dynamic>> wallets) {
    try {
      return wallets.firstWhere((wallet) => wallet['Name'] == 'Tiền mặt');
    } catch (e) {
      return null;
    }
  }

  // Định dạng ngày giờ thành chuỗi dễ đọc
  String formatDate(DateTime date) {
    return DateFormat('EEEE d/M/y').format(date);
  }

  // Kiểm tra dữ liệu giao dịch, trả về lỗi nếu có
  String? validateTransaction({
    required double amount,
    required int? walletId,
    required int? categoryId,
  }) {
    if (amount <= 0) {
      return 'Số tiền phải lớn hơn 0';
    }
    if (walletId == null) {
      return 'Vui lòng chọn ví';
    }
    if (categoryId == null) {
      return 'Vui lòng chọn danh mục';
    }
    return null;
  }

  // Chuyển đổi chuỗi số tiền thành double
  double parseAmount(String amountText) {
    return double.tryParse(amountText.replaceAll(',', '')) ?? 0;
  }

  // Lưu khoản chi vào database
  Future<int> saveExpense({
    required double amount,
    required int walletId,
    required int categoryId,
    required String note,
    required DateTime dateTime,
  }) async {
    return await _dbHelper.insertTransaction(
      type: 'expense',
      amount: amount,
      walletId: walletId,
      categoryId: categoryId,
      note: note,
      dateTime: dateTime,
    );
  }
}
