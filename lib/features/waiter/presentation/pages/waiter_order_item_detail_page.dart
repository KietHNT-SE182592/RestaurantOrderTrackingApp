import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/status_enums.dart';
import '../../domain/entities/table_detail_entity.dart';

class WaiterOrderItemDetailPage extends StatelessWidget {
  final TableOrderItemSummaryEntity? item;

  const WaiterOrderItemDetailPage({super.key, required this.item});

  String _formatVnd(int amount) {
    final digits = amount.toString();
    final buffer = StringBuffer();

    for (var i = 0; i < digits.length; i++) {
      final reverseIndex = digits.length - i;
      buffer.write(digits[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write('.');
      }
    }

    return '${buffer.toString()} đ';
  }

  Color _statusColor(OrderItemStatus status) {
    switch (status) {
      case OrderItemStatus.confirmed:
      case OrderItemStatus.ready:
      case OrderItemStatus.served:
        return const Color(0xFF22C55E);
      case OrderItemStatus.cooking:
      case OrderItemStatus.delivering:
        return const Color(0xFFF59E0B);
      case OrderItemStatus.cancelled:
        return const Color(0xFFEF4444);
      default:
        return AppColors.secondary;
    }
  }

  String _formatDateTime(DateTime? value) {
    if (value == null) return 'Chưa cập nhật';
    final local = value.toLocal();

    String twoDigits(int number) => number.toString().padLeft(2, '0');

    final date =
        '${twoDigits(local.day)}/${twoDigits(local.month)}/${local.year}';
    final time = '${twoDigits(local.hour)}:${twoDigits(local.minute)}';
    return '$time - $date';
  }

  @override
  Widget build(BuildContext context) {
    final currentItem = item;

    if (currentItem == null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          title: const Text('Chi tiết món'),
          backgroundColor: AppColors.backgroundLight,
          elevation: 0,
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Không có dữ liệu món. Vui lòng quay lại trang trước và thử lại.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final lineTotal = currentItem.price * currentItem.quantity;
    final statusColor = _statusColor(currentItem.status);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Chi tiết món'),
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.accent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentItem.productName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'x${currentItem.quantity}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          currentItem.status.viLabel,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _InfoCard(
              title: 'Thông tin chính',
              children: [
                _InfoRow(
                  label: 'Đơn giá',
                  value: _formatVnd(currentItem.price),
                ),
                _InfoRow(label: 'Số lượng', value: '${currentItem.quantity}'),
                _InfoRow(label: 'Thành tiền', value: _formatVnd(lineTotal)),
                _InfoRow(
                  label: 'Kênh gọi',
                  value: currentItem.orderChannel ?? '-',
                ),
              ],
            ),
            const SizedBox(height: 12),
            _InfoCard(
              title: 'Phân công',
              children: [
                _InfoRow(
                  label: 'Bếp phụ trách',
                  value: currentItem.chefName ?? '-',
                ),
                _InfoRow(
                  label: 'Phục vụ phụ trách',
                  value: currentItem.waiterName ?? '-',
                ),
              ],
            ),
            const SizedBox(height: 12),
            _InfoCard(
              title: 'Thời gian',
              children: [
                _InfoRow(
                  label: 'Tạo lúc',
                  value: _formatDateTime(currentItem.createdAt),
                ),
                _InfoRow(
                  label: 'Cập nhật lần cuối',
                  value: _formatDateTime(currentItem.updatedAt),
                ),
              ],
            ),
            if ((currentItem.note ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              _InfoCard(
                title: 'Ghi chú',
                children: [
                  Text(
                    currentItem.note!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _InfoCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.mutedForeground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
