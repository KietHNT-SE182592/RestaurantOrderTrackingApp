import 'package:flutter/material.dart';

import '../../../../../core/shared_features/widgets/placeholder_body.dart';

class ManagerInventoryPage extends StatelessWidget {
  const ManagerInventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: PlaceholderBody(
        icon: Icons.inventory_2,
        title: 'Quản lý Kho',
        subtitle: 'Nhập hàng, tồn kho, cảnh báo hết hàng, lịch sử giao dịch',
      ),
    );
  }
}
