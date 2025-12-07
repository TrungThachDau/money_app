import 'package:money_app/app/db_helper.dart';

class StatisticService {
  final DBHelper _dbHelper = DBHelper();

  /// Lấy danh sách chi tiêu theo danh mục trong tháng
  Future<List<Map<String, dynamic>>> getExpenseByCategoryInMonth(DateTime month) {
    return _dbHelper.getExpenseByCategoryInMonth(month);
  }

  /// Lấy tổng chi tiêu trong tháng
  Future<double> getTotalExpenseInMonth(DateTime month) {
    return _dbHelper.getTotalExpenseInMonth(month);
  }

  /// Tính tháng mới dựa trên tháng hiện tại và delta
  DateTime calculateNewMonth(DateTime currentMonth, int delta) {
    return DateTime(currentMonth.year, currentMonth.month + delta);
  }

  /// Tính phần trăm chi tiêu
  double calculatePercentage(double amount, double total) {
    return (total > 0) ? (amount / total * 100) : 0.0;
  }

  /// Format số tiền hiển thị
  String formatAmount(double amount) {
    return '${amount.toStringAsFixed(0)}đ';
  }

  /// Format phần trăm hiển thị
  String formatPercentage(double percent) {
    return '${percent.toStringAsFixed(1)}%';
  }

  /// Format tháng hiển thị
  String formatMonth(DateTime month) {
    return '${month.month.toString().padLeft(2, '0')}/${month.year}';
  }
}
