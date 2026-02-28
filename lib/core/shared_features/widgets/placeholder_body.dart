import 'package:flutter/material.dart';

/// Widget placeholder dùng chung cho tất cả skeleton pages.
/// Xóa file này sau khi triển khai UI thực tế.
class PlaceholderBody extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const PlaceholderBody({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 72, color: Colors.blueGrey.shade200),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
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
    );
  }
}
