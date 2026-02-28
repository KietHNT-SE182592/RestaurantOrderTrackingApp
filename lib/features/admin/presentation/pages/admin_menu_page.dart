import 'package:flutter/material.dart';

import '../../../../../core/shared_features/widgets/placeholder_body.dart';

class AdminMenuPage extends StatelessWidget {
  const AdminMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: PlaceholderBody(
        icon: Icons.restaurant_menu,
        title: 'Quản lý Menu',
        subtitle: 'Thêm / sửa / xóa món, danh mục, giá, trạng thái',
      ),
    );
  }
}
