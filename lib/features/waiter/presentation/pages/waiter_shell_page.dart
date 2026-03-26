import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Shell của Waiter — BottomNavigationBar 3 tabs.
class WaiterShellPage extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const WaiterShellPage({super.key, required this.navigationShell});

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onTap,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.point_of_sale_outlined),
            selectedIcon: Icon(Icons.point_of_sale),
            label: 'Gọi món',
          ),
          NavigationDestination(
            icon: Icon(Icons.table_restaurant_outlined),
            selectedIcon: Icon(Icons.table_restaurant),
            label: 'Sơ đồ bàn',
          ),
          NavigationDestination(
            icon: Icon(Icons.room_service_outlined),
            selectedIcon: Icon(Icons.room_service),
            label: 'Ra món',
          ),
        ],
      ),
    );
  }
}
