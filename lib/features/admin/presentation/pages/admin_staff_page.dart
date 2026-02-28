import 'package:flutter/material.dart';

import '../../../../../core/shared_features/widgets/placeholder_body.dart';

class AdminStaffPage extends StatelessWidget {
  const AdminStaffPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: PlaceholderBody(
        icon: Icons.people,
        title: 'Quản lý Nhân viên',
        subtitle: 'Danh sách, phân quyền, lịch làm việc, hiệu suất',
      ),
    );
  }
}
