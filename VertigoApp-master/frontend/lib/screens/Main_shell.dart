import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/app_settings.dart';
import 'home_screen.dart';
import 'orders_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    OrdersScreen(),
    FavoritesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();
    final t = settings.t;

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: VertigoTheme.primaryGreen,
        unselectedItemColor: VertigoTheme.textGrey,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: t('deals'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.shopping_bag),
            label: t('orders'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.favorite),
            label: t('favorites'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: t('profile'),
          ),
        ],
      ),
    );
  }
}
