import 'package:flutter/material.dart';
import 'service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeService _service = HomeService();

  // Trạng thái UI
  DateTime? _selectedDate;
  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> wallets = [];
  int? _selectedCategoryId;
  int? _selectedWalletId;

  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _amountController = TextEditingController(text: '0');

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Tải dữ liệu danh mục và ví
  Future<void> _loadData() async {
    final loadedCategories = await _service.loadCategories();
    final loadedWallets = await _service.loadWallets();
    setState(() {
      categories = loadedCategories;
      wallets = loadedWallets;
      final defaultWallet = _service.getDefaultWallet(wallets);
      if (defaultWallet != null) {
        _selectedWalletId = defaultWallet['Id'];
      }
    });
  }

  // Tải lại danh sách danh mục
  Future<void> _refreshCategories() async {
    final loadedCategories = await _service.loadCategories();
    setState(() {
      categories = loadedCategories;
    });
  }

  // Hiển thị thông báo tại đáy màn hình
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  // Hiển thị hộp thoại kết quả
  void _showResultDialog({required String title, required String content}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Đặt lại form về trạng thái ban đầu
  void _resetForm() {
    setState(() {
      _amountController.text = '0';
      _noteController.clear();
      _selectedCategoryId = null;
      _selectedDate = null;
      final defaultWallet = _service.getDefaultWallet(wallets);
      _selectedWalletId = defaultWallet?['Id'];
    });
  }

  // Xử lý lưu khoản chi
  Future<void> _handleSaveExpense() async {
    final amount = _service.parseAmount(_amountController.text);
    final validationError = _service.validateTransaction(
      amount: amount,
      walletId: _selectedWalletId,
      categoryId: _selectedCategoryId,
    );

    if (validationError != null) {
      _showSnackBar(validationError);
      return;
    }

    final date = _selectedDate ?? DateTime.now();
    try {
      final insertedId = await _service.saveExpense(
        amount: amount,
        walletId: _selectedWalletId!,
        categoryId: _selectedCategoryId!,
        note: _noteController.text,
        dateTime: date,
      );

      if (!mounted) return;

      if (insertedId > 0) {
        _showSnackBar('Lưu khoản chi thành công!');
        _resetForm();
      } else {
        _showResultDialog(title: 'Lỗi', content: 'Không thể lưu khoản chi. Vui lòng thử lại.');
      }
    } catch (e) {
      if (!mounted) return;
      _showResultDialog(title: 'Lỗi', content: 'Lỗi lưu dữ liệu: ${e.toString()}');
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Nhập'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _buildDateField(),
                  _buildNoteField(),
                  _buildAmountField(),
                  _buildWalletDropdown(),
                  _buildCategorySection(),
                ],
              ),
            ),
          ),
          _buildSaveButton(),
        ],
      ),
    );
  }

  // Xây dựng trường ngày tháng
  Widget _buildDateField() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          const SizedBox(width: 70, child: Text('Ngày')),
          const SizedBox(width: 16),
          Expanded(
            child: InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  setState(() {
                    _selectedDate = picked;
                  });
                }
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: Text(_service.formatDate(_selectedDate ?? DateTime.now())),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Xây dựng trường ghi chú
  Widget _buildNoteField() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          const SizedBox(width: 70, child: Text('Ghi chú')),
          const SizedBox(width: 16),
          Expanded(
            child: TextFormField(
              controller: _noteController,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
                hintText: 'Nhập ghi chú',
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Xây dựng trường số tiền
  Widget _buildAmountField() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          const SizedBox(width: 70, child: Text('Số tiền')),
          const SizedBox(width: 16),
          Expanded(
            child: TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
                prefix: const Text('₫ '),
                hintText: 'Nhập số tiền',
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Xây dựng dropdown chọn ví
  Widget _buildWalletDropdown() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          const SizedBox(width: 70, child: Text('Ví')),
          const SizedBox(width: 16),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return DropdownMenu<int>(
                  width: constraints.maxWidth,
                  initialSelection: _selectedWalletId,
                  hintText: 'Chọn ví',
                  inputDecorationTheme: InputDecorationTheme(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  dropdownMenuEntries: wallets.map((wallet) {
                    return DropdownMenuEntry<int>(
                      value: wallet['Id'] as int,
                      label: wallet['Name'] as String,
                    );
                  }).toList(),
                  onSelected: (value) {
                    setState(() {
                      _selectedWalletId = value;
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Xây dựng phần chọn danh mục
  Widget _buildCategorySection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Danh mục', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              TextButton.icon(
                onPressed: () async {
                  await Navigator.of(context).pushNamed('/category');
                  _refreshCategories();
                },
                icon: const Icon(Icons.settings, size: 18),
                label: const Text('Quản lý'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          categories.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Chưa có danh mục nào'),
                  ),
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: categories.map((category) {
                    final isSelected = _selectedCategoryId == category['Id'];
                    return FilterChip(
                      label: Text(category['Name']),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategoryId = selected ? category['Id'] : null;
                        });
                      },
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }

  // Xây dựng nút lưu
  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: _handleSaveExpense,
          child: const Text('Nhập khoản chi'),
        ),
      ),
    );
  }
}
