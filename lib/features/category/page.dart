import 'package:flutter/material.dart';

import 'service.dart';

// Tạo một instance duy nhất của service được sử dụng bởi trang này
final CategoryService _categoryService = CategoryService();

// Lớp trang danh mục, kế thừa từ StatefulWidget để quản lý trạng thái
class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

// Lớp trạng thái cho CategoryPage
class _CategoryPageState extends State<CategoryPage> {
  List<Map<String, dynamic>> categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  // Hàm tải danh sách danh mục từ service
  Future<void> _loadCategories() async {
    final data = await _categoryService.getCategories();

    setState(() {
      categories = data;
    });
  }

  // Hàm thêm danh mục mới
  Future<void> _addCategory() async {
    final nameController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm danh mục mới'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Tên danh mục',
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
              final result = await _categoryService.addCategory(
                nameController.text,
              );
              if (result > 0) {
                await _loadCategories();
                if (context.mounted) {
                  Navigator.pop(context);
                }
              }
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  // Hàm sửa danh mục
  Future<void> _editCategory(int id, String currentName) async {
    final nameController = TextEditingController(text: currentName);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sửa danh mục'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Tên danh mục',
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
              final result = await _categoryService.updateCategory(
                id,
                nameController.text,
              );
              if (result > 0) {
                await _loadCategories();
                if (context.mounted) {
                  Navigator.pop(context);
                }
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  // Hàm xóa danh mục
  Future<void> _deleteCategory(int id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa danh mục "$name"?'),
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
      await _categoryService.deleteCategory(id);
      await _loadCategories();
    }
  }

  // Xây dựng giao diện người dùng
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Danh mục')),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final item = categories[index];

          return ListTile(
            leading: const Icon(Icons.label),
            title: Text(item['Name']),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _editCategory(item['Id'], item['Name']),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteCategory(item['Id'], item['Name']),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCategory,
        child: const Icon(Icons.add),
      ),
    );
  }
}
