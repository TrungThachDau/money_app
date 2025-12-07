import 'package:flutter/material.dart';
import 'package:money_app/app/route.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Khác'),
        automaticallyImplyLeading: false, // Ẩn nút lùi
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Quản lí danh mục'),
            onTap: () {
              Navigator.of(context).pushNamed(AppRoutes.category);
            },
          ),
          ListTile(
            leading: const Icon(Icons.wallet),
            title: const Text('Quản lí Ví'),
            onTap: () {
              Navigator.of(context).pushNamed(AppRoutes.wallet);
            },
          ),
          // Thêm các cài đặt khác ở đây nếu cần
        ],
      ),
    );
  }
}
