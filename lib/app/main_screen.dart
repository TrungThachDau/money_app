import 'package:flutter/material.dart';
import '../features/home/page.dart';
import '../features/more/page.dart';
import '../features/statistic/page.dart';
import 'app_navbar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const <Widget>[
    HomePage(),
    Center(child: Text('Settings Page')),
    StatisticPage(),
    MorePage(), // Sử dụng trang Khác mới tạo
  ];

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: MainNavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onDestinationSelected,
      ),
    );
  }
}
