import 'package:flutter/material.dart';
import 'wallet_service.dart';

final WalletService _walletService = WalletService();

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  List<Map<String, dynamic>> wallets = [];

  @override
  void initState() {
    super.initState();
    _loadWallets();
  }

  /// Tải danh sách ví từ database
  Future<void> _loadWallets() async {
    final data = await _walletService.getWallets();
    setState(() => wallets = data);
  }

  /// Thêm ví mới
  Future<void> _addWallet() async {
    final nameController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm ví mới'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Tên ví',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isNotEmpty) {
                await _walletService.addWallet(nameController.text.trim());
                await _loadWallets();
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  /// Sửa thông tin ví
  Future<void> _editWallet(int id, String currentName) async {
    final nameController = TextEditingController(text: currentName);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sửa ví'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Tên ví',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isNotEmpty) {
                await _walletService.updateWallet(
                  id,
                  nameController.text.trim(),
                );
                await _loadWallets();
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  /// Xóa ví
  Future<void> _deleteWallet(int id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa ví "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _walletService.deleteWallet(id);
      await _loadWallets();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ví')),
      body: ListView.builder(
        itemCount: wallets.length,
        itemBuilder: (context, index) {
          final item = wallets[index];
          return ListTile(
            leading: const Icon(Icons.account_balance_wallet),
            title: Text(item['Name'] ?? ''),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _editWallet(item['Id'], item['Name']),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteWallet(item['Id'], item['Name']),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addWallet,
        child: const Icon(Icons.add),
      ),
    );
  }
}
