import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/status_enums.dart';
import '../../../../di/injection.dart';
import '../../domain/entities/order_detail_entity.dart';
import '../cubit/order_detail_cubit.dart';

class OrderDetailPage extends StatelessWidget {
  final String orderId;

  const OrderDetailPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<OrderDetailCubit>()..loadOrderDetail(orderId),
      child: _OrderDetailView(orderId: orderId),
    );
  }
}

class _OrderDetailView extends StatelessWidget {
  final String orderId;

  const _OrderDetailView({required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        title: const Text('Chi tiết đơn hàng'),
      ),
      body: BlocBuilder<OrderDetailCubit, OrderDetailState>(
        builder: (context, state) {
          if (state is OrderDetailLoading || state is OrderDetailInitial) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (state is OrderDetailError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: () => context.read<OrderDetailCubit>().retry(),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            );
          }
          if (state is OrderDetailLoaded) {
            return _OrderDetailContent(order: state.order);
          }
          return const SizedBox.shrink();
        },
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () =>
                  context.push(AppRoutes.waiterOrderMenuOf(orderId)),
              icon: const Icon(Icons.restaurant_menu_rounded),
              label: const Text('Gọi món'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                textStyle: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OrderDetailContent extends StatelessWidget {
  final OrderDetailEntity order;

  const _OrderDetailContent({required this.order});

  Color get _statusColor {
    switch (order.status) {
      case OrderStatus.confirmed:
        return const Color(0xFF0EA5E9);
      case OrderStatus.completed:
        return const Color(0xFF22C55E);
      case OrderStatus.cancelled:
        return const Color(0xFFEF4444);
      default:
        return AppColors.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Bàn ${order.tableNumber}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      order.status.viLabel,
                      style: TextStyle(
                        color: _statusColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('Order ID: ${order.id}'),
              const SizedBox(height: 4),
              Text('Loại đơn: ${order.orderType}'),
              const SizedBox(height: 4),
              Text('Phục vụ: ${order.waiterName ?? '-'}'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Món trong đơn (${order.orderItems.length})',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...order.orderItems.map(
          (item) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.productName,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      item.status.viLabel,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text('Giá: ${item.productPrice} VND'),
                if ((item.note ?? '').isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text('Ghi chú: ${item.note}'),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
