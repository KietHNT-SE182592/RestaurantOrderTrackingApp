import 'package:flutter/material.dart';

import '../../../../../core/shared_features/widgets/placeholder_body.dart';

class WaiterTablesPage extends StatelessWidget {
  const WaiterTablesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: PlaceholderBody(
        icon: Icons.table_restaurant,
        title: 'Sơ đồ Bàn',
        subtitle: 'Xem bàn trống / đang phục vụ, chọn bàn để gọi món',
      ),
    );
  }
}
