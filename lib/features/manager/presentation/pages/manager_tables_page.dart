import 'package:flutter/material.dart';

import '../../../../../core/shared_features/widgets/placeholder_body.dart';

class ManagerTablesPage extends StatelessWidget {
  const ManagerTablesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: PlaceholderBody(
        icon: Icons.table_restaurant,
        title: 'Sơ đồ Bàn ăn',
        subtitle: 'Trạng thái từng bàn, ghép bàn, đặt trước, chuyển bàn',
      ),
    );
  }
}
