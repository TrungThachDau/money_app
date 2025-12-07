import 'package:flutter/material.dart';
import 'package:money_app/app/main_screen.dart';
import 'package:money_app/features/category/page.dart';
import 'package:money_app/features/wallet/page.dart';
import 'package:money_app/features/statistic/page.dart';



class AppRoutes {
  static const String home = '/home';
  static const String wallet = '/wallet';
  static const String settings = '/settings';
  static const String more = '/more';
  static const String category = '/category'; // Thêm route cho category
  static const String statistic = '/statistic'; // Thêm route cho statistic

  // Add a static generateRoute method for MaterialApp
  static Route<dynamic> generateRoute(RouteSettings settings) {
    return AppRouter.generateRoute(settings);
  }
}

class AppRouter {

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const MainScreen());
      case AppRoutes.settings:
        return MaterialPageRoute(
            builder: (_) => const Center(child: Text('Settings Page')));
      case AppRoutes.more:
        return MaterialPageRoute(
            builder: (_) => const Center(child: Text('More Page')));
      case AppRoutes.category:
        return MaterialPageRoute(builder: (_) => const CategoryPage());
      case AppRoutes.wallet:
        return MaterialPageRoute(builder: (_)=> const WalletPage());
      case AppRoutes.statistic:
        return MaterialPageRoute(builder: (_)=> const StatisticPage());
      default:
        // Nếu là màn hình Home, trả về MainScreen (màn hình chính)
        if (settings.name == Navigator.defaultRouteName || settings.name == '/') {
          return MaterialPageRoute(builder: (_) => const MainScreen());
        }
        return MaterialPageRoute(
            builder: (_) => const Scaffold(
                  body: Center(child: Text('No route defined')),
                ));
    }
  }
}
