import 'package:flutter/material.dart';

import '../../../../../core/shared_features/widgets/placeholder_body.dart';

class ManagerReportsPage extends StatelessWidget {
  const ManagerReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: PlaceholderBody(
        icon: Icons.bar_chart,
        title: 'Báo cáo & Thống kê',
        subtitle: 'Doanh thu theo ca / ngày, hiệu suất bàn, tốc độ bếp',
      ),
    );
  }
}
