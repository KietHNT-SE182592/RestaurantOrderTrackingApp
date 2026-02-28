import 'package:flutter/material.dart';

import '../../../../../core/shared_features/widgets/placeholder_body.dart';

class AdminReportsPage extends StatelessWidget {
  const AdminReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: PlaceholderBody(
        icon: Icons.bar_chart,
        title: 'Báo cáo & Thống kê',
        subtitle: 'Doanh thu theo ngày / tháng, món bán chạy, giờ cao điểm',
      ),
    );
  }
}
