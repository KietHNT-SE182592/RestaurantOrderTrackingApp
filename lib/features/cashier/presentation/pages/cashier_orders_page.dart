import 'package:flutter/material.dart';


class CashierOrdersPage extends StatelessWidget {
  const CashierOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hàng chờ thanh toán')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.receipt_long, size: 72, color: Colors.blueGrey.shade200),
              const SizedBox(height: 16),
              Text('Danh sách Đơn hàng', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                'Các đơn đã hoàn thiện, chờ thanh toán',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Placeholder: button dẫn tới checkout
              FilledButton.icon(
                onPressed: () {
                  // TODO: truyền orderId thực tế
                  // context.push(AppRoutes.cashierCheckoutOf('test-order-id'));
                },
                icon: const Icon(Icons.payments_outlined),
                label: const Text('Thanh toán'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
