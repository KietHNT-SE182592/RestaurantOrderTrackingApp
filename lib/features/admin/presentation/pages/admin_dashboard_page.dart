import 'package:flutter/material.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: const _PlaceholderBody(
        icon: Icons.dashboard,
        title: 'Admin Dashboard',
        subtitle: 'KPI tổng quan, doanh thu, số bàn, đơn hàng hôm nay',
      ),
    );
  }
}

class _PlaceholderBody extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _PlaceholderBody({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 72, color: Colors.blueGrey.shade200),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Chip(
              avatar: const Icon(Icons.build_outlined, size: 16),
              label: const Text('Chưa triển khai'),
              backgroundColor: Colors.orange.shade50,
            ),
          ],
        ),
      ),
    );
  }
}
