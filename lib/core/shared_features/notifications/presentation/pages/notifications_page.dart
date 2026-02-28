import 'package:flutter/material.dart';

/// Màn hình thông báo — dùng chung cho tất cả role.
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thông báo')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_outlined, size: 72, color: Colors.blueGrey.shade200),
            const SizedBox(height: 16),
            Text('Thông báo', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'Cập nhật đơn hàng, ca làm, tồn kho...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
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
