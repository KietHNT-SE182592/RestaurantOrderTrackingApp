import 'package:flutter/material.dart';

/// Màn hình thanh toán cho một đơn hàng cụ thể.
/// [orderId] được truyền vào từ GoRouter path parameter.
class CashierCheckoutPage extends StatelessWidget {
  final String orderId;

  const CashierCheckoutPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Thanh toán #$orderId')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.payments, size: 72, color: Colors.blueGrey.shade200),
              const SizedBox(height: 16),
              Text('Thanh toán Đơn hàng', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                'Order ID: $orderId',
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
      ),
    );
  }
}
