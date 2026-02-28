import 'package:flutter/material.dart';

/// Kitchen Display System (KDS) — màn hình chính của Chef.
/// Hiển thị danh sách order đang chờ xử lý theo thời gian thực.
class KitchenDisplayPage extends StatelessWidget {
  const KitchenDisplayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade900,
        foregroundColor: Colors.white,
        title: const Text(
          '🍳 Kitchen Display System',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined),
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant, size: 72, color: Colors.white24),
            SizedBox(height: 16),
            Text(
              'Kitchen Display System',
              style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Danh sách ticket đang chờ, đang làm, hoàn thành',
              style: TextStyle(color: Colors.white54),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            Chip(
              label: Text('Chưa triển khai', style: TextStyle(color: Colors.orange)),
              backgroundColor: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }
}
