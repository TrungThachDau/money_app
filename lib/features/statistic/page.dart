import 'package:flutter/material.dart';
import 'package:money_app/features/statistic/service.dart';

class StatisticPage extends StatefulWidget {
  const StatisticPage({super.key});

  @override
  State<StatisticPage> createState() => _StatisticPageState();
}

class _StatisticPageState extends State<StatisticPage> {
  final StatisticService _service = StatisticService();
  late Future<List<Map<String, dynamic>>> _expenseByCategoryFuture;
  late Future<double> _totalExpenseFuture;
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _expenseByCategoryFuture = _service.getExpenseByCategoryInMonth(_selectedMonth);
    _totalExpenseFuture = _service.getTotalExpenseInMonth(_selectedMonth);
  }

  void _changeMonth(int delta) {
    setState(() {
      _selectedMonth = _service.calculateNewMonth(_selectedMonth, delta);
      _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thống kê'),
        automaticallyImplyLeading: false, // Ẩn nút lùi
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12, left: 16, right: 16, bottom: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => _changeMonth(-1),
                ),
                Text(
                  _service.formatMonth(_selectedMonth),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => _changeMonth(1),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<double>(
              future: _totalExpenseFuture,
              builder: (context, totalSnapshot) {
                final total = totalSnapshot.data ?? 0.0;
                return ListView(
                  children: [
                    Card(
                      margin: const EdgeInsets.all(16),
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.red.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.all(12),
                              child: const Icon(Icons.trending_down, color: Colors.red, size: 32),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Tổng chi tháng này', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                Text(_service.formatAmount(total), style: const TextStyle(fontSize: 20, color: Colors.red, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        'Chi theo danh mục',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: _expenseByCategoryFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('Không có dữ liệu chi tiêu.'),
                          );
                        }
                        final data = snapshot.data!;
                        if (data.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('Không có dữ liệu chi tiêu.'),
                          );
                        }
                        return Column(
                          children: data.map((cat) {
                            final amount = (cat['Total'] as num?)?.toDouble() ?? 0.0;
                            final percent = _service.calculatePercentage(amount, total);
                            return ListTile(
                              leading: const Icon(Icons.category, color: Colors.grey),
                              title: Text(cat['Name'] ?? ''),
                              trailing: Text(
                                '${_service.formatAmount(amount)} (${_service.formatPercentage(percent)})',
                                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                    const Divider(),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
