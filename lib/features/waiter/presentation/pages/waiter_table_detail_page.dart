import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/status_enums.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/jwt_decoder.dart';
import '../../../../di/injection.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../domain/entities/table_detail_entity.dart';
import '../cubit/table_detail_cubit.dart';

class WaiterTableDetailPage extends StatelessWidget {
  final String tableId;

  const WaiterTableDetailPage({super.key, required this.tableId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<TableDetailCubit>()..loadTableDetail(tableId),
      child: const _WaiterTableDetailView(),
    );
  }
}

class _WaiterTableDetailView extends StatelessWidget {
  const _WaiterTableDetailView();

  Future<void> _goToOrderMenu(BuildContext context, String orderId) async {
    await context.push(AppRoutes.waiterOrderMenuOf(orderId));
    if (!context.mounted) return;
    await context.read<TableDetailCubit>().retry();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: BlocBuilder<TableDetailCubit, TableDetailState>(
        builder: (context, state) {
          if (state is TableDetailLoading || state is TableDetailInitial) {
            return const _LoadingView();
          }
          if (state is TableDetailError) {
            return _ErrorView(
              message: state.message,
              onRetry: () => context.read<TableDetailCubit>().retry(),
            );
          }
          if (state is TableDetailLoaded) {
            return _DetailContent(
              table: state.table,
              isCreatingOrder: state.isCreatingOrder,
            );
          }
          return const SizedBox.shrink();
        },
      ),
      bottomNavigationBar: BlocBuilder<TableDetailCubit, TableDetailState>(
        builder: (context, state) {
          if (state is! TableDetailLoaded) {
            return const SizedBox.shrink();
          }
          final orderId = state.table.activeOrder?.id;
          if (orderId == null || orderId.isEmpty) {
            return const SizedBox.shrink();
          }

          return SafeArea(
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
                  onPressed: () => _goToOrderMenu(context, orderId),
                  icon: const Icon(Icons.restaurant_menu_rounded),
                  label: const Text('Gọi món'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    textStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Detail Content ───────────────────────────────────────────────────────────

class _DetailContent extends StatelessWidget {
  final TableDetailEntity table;
  final bool isCreatingOrder;

  const _DetailContent({required this.table, required this.isCreatingOrder});

  Color get _statusColor {
    switch (table.status) {
      case TableStatus.available:
        return const Color(0xFF22C55E);
      case TableStatus.occupied:
        return const Color(0xFFEF4444);
      case TableStatus.reserved:
        return AppColors.secondary;
      default:
        return AppColors.mutedForeground;
    }
  }

  String get _statusLabel => table.status.viLabel;

  Future<void> _handleCreateOrder(BuildContext context) async {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phiên đăng nhập đã hết hạn.')),
      );
      return;
    }

    final accountId =
        JwtDecoder.extractId(authState.user.accessToken) ?? authState.user.id;
    if (accountId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không lấy được thông tin tài khoản.')),
      );
      return;
    }

    try {
      final orderId = await context
          .read<TableDetailCubit>()
          .createOrderForCurrentTable(accountId: accountId);
      if (!context.mounted) return;

      if (orderId != null && orderId.isNotEmpty) {
        await context.push(AppRoutes.waiterOrderMenuOf(orderId));
        if (!context.mounted) return;
        await context.read<TableDetailCubit>().retry();
      }
    } on ServerFailure {
      if (!context.mounted) return;
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể tạo đơn. Vui lòng thử lại.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _buildAppBar(context),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroCard(context),
                const SizedBox(height: 20),
                _buildOrdersSection(context),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      backgroundColor: AppColors.backgroundLight,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              color: AppColors.foregroundLight,
              size: 22,
            ),
          ),
        ),
      ),
      title: Text(
        'Chi tiết Bàn',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.foregroundLight,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildHeroCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _statusLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.table_restaurant_rounded,
                color: Colors.white54,
                size: 32,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Bàn ${table.tableNumber}',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.location_on_rounded,
                size: 16,
                color: Colors.white70,
              ),
              const SizedBox(width: 4),
              Text(
                table.areaName,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _HeroInfoPill(
                icon: Icons.people_alt_rounded,
                label: 'Sức chứa',
                value: '${table.capacity} khách',
              ),
              _HeroInfoPill(
                icon: Icons.map_rounded,
                label: 'Khu vực',
                value: table.areaName,
              ),
              if ((table.qrCode ?? '').isNotEmpty)
                _HeroInfoPill(
                  icon: Icons.qr_code_rounded,
                  label: 'Mã QR',
                  value: table.qrCode!,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Đơn hàng hiện tại',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.foregroundLight,
              ),
            ),
            const SizedBox(width: 8),
            if (table.hasActiveOrder)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '1',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (!table.hasActiveOrder)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 26, 16, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.receipt_long_outlined,
                  size: 40,
                  color: AppColors.mutedForeground,
                ),
                const SizedBox(height: 8),
                Text(
                  'Chưa có đơn hàng',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
                const SizedBox(height: 16),
                if (table.isAvailable)
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: isCreatingOrder
                          ? null
                          : () => _handleCreateOrder(context),
                      icon: isCreatingOrder
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.add_circle_outline_rounded),
                      label: Text(
                        isCreatingOrder ? 'Đang tạo đơn...' : 'Tạo đơn mới',
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        textStyle: Theme.of(context).textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                  )
                else
                  Text(
                    'Chỉ tạo đơn khi bàn ở trạng thái Trống.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.mutedForeground,
                    ),
                  ),
              ],
            ),
          )
        else
          Column(
            children: [
              _ActiveOrderCard(order: table.activeOrder!),
              const SizedBox(height: 14),
              _OrderItemsSection(order: table.activeOrder!),
            ],
          ),
      ],
    );
  }
}

class _HeroInfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _HeroInfoPill({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 120, maxWidth: 180),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white70),
          const SizedBox(width: 6),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white70,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Active Order Card ────────────────────────────────────────────────────────

class _ActiveOrderCard extends StatelessWidget {
  final TableOrderSummaryEntity order;

  const _ActiveOrderCard({required this.order});

  String _formatVnd(int amount) {
    final isNegative = amount < 0;
    final digits = amount.abs().toString();
    final buffer = StringBuffer();

    for (var i = 0; i < digits.length; i++) {
      final reverseIndex = digits.length - i;
      buffer.write(digits[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write('.');
      }
    }

    return '${isNegative ? '-' : ''}${buffer.toString()} đ';
  }

  Color _orderStatusColor(OrderStatus status) {
    switch (status) {
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
    final orderStatusColor = _orderStatusColor(order.status);
    final totalText = _formatVnd(order.totalAmount);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              size: 18,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${order.totalItems} món trong đơn',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.mutedForeground,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  totalText,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.foregroundLight,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: orderStatusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              order.status.viLabel,
              style: TextStyle(
                color: orderStatusColor,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderItemsSection extends StatefulWidget {
  final TableOrderSummaryEntity order;

  const _OrderItemsSection({required this.order});

  @override
  State<_OrderItemsSection> createState() => _OrderItemsSectionState();
}

class _OrderItemsSectionState extends State<_OrderItemsSection> {
  late _OrderItemFilterOption _selectedFilter;

  static const List<_OrderItemFilterOption> _filterOptions = [
    _OrderItemFilterOption(label: 'Tất cả'),
    _OrderItemFilterOption(
      label: 'Chờ xác nhận',
      status: OrderItemStatus.pending,
    ),
    _OrderItemFilterOption(
      label: 'Đã xác nhận',
      status: OrderItemStatus.confirmed,
    ),
    _OrderItemFilterOption(label: 'Đang nấu', status: OrderItemStatus.cooking),
    _OrderItemFilterOption(
      label: 'Sẵn sàng phục vụ',
      status: OrderItemStatus.ready,
    ),
    _OrderItemFilterOption(
      label: 'Đang mang ra',
      status: OrderItemStatus.delivering,
    ),
    _OrderItemFilterOption(label: 'Đã phục vụ', status: OrderItemStatus.served),
    _OrderItemFilterOption(label: 'Đã hủy', status: OrderItemStatus.cancelled),
  ];

  static const Map<OrderItemStatus, int> _statusSortOrder = {
    OrderItemStatus.pending: 0,
    OrderItemStatus.confirmed: 1,
    OrderItemStatus.cooking: 2,
    OrderItemStatus.ready: 3,
    OrderItemStatus.delivering: 4,
    OrderItemStatus.served: 5,
    OrderItemStatus.cancelled: 6,
    OrderItemStatus.unknown: 7,
  };

  @override
  void initState() {
    super.initState();
    _selectedFilter = _filterOptions.first;
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = widget.order.orderItems.where((item) {
      final selectedStatus = _selectedFilter.status;
      if (selectedStatus == null) return true;
      return item.status == selectedStatus;
    }).toList();

    filteredItems.sort((a, b) {
      final rankA = _statusSortOrder[a.status] ?? 999;
      final rankB = _statusSortOrder[b.status] ?? 999;
      if (rankA != rankB) return rankA.compareTo(rankB);

      final timeA = a.createdAt?.millisecondsSinceEpoch ?? 0;
      final timeB = b.createdAt?.millisecondsSinceEpoch ?? 0;
      return timeA.compareTo(timeB);
    });

    final totalQuantity = filteredItems.fold<int>(
      0,
      (sum, item) => sum + item.quantity,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Món trong đơn ($totalQuantity)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.foregroundLight,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              constraints: const BoxConstraints(minHeight: 40, maxWidth: 190),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<_OrderItemFilterOption>(
                  value: _selectedFilter,
                  isDense: true,
                  iconSize: 18,
                  borderRadius: BorderRadius.circular(12),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.foregroundLight,
                    fontWeight: FontWeight.w600,
                  ),
                  items: _filterOptions
                      .map(
                        (option) => DropdownMenuItem<_OrderItemFilterOption>(
                          value: option,
                          child: Text(
                            option.label,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _selectedFilter = value;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (filteredItems.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              'Không có món ở trạng thái ${_selectedFilter.label.toLowerCase()}.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.mutedForeground),
            ),
          )
        else
          ...filteredItems.map(
            (item) => _OrderItemTile(item: item, orderId: widget.order.id),
          ),
      ],
    );
  }
}

class _OrderItemFilterOption {
  final String label;
  final OrderItemStatus? status;

  const _OrderItemFilterOption({required this.label, this.status});
}

class _OrderItemTile extends StatelessWidget {
  final TableOrderItemSummaryEntity item;
  final String orderId;

  const _OrderItemTile({required this.item, required this.orderId});

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

  Color _itemStatusColor(OrderItemStatus status) {
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

  @override
  Widget build(BuildContext context) {
    final lineTotal = item.price * item.quantity;
    final itemStatusColor = _itemStatusColor(item.status);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => context.push(
            AppRoutes.waiterOrderItemDetailOf(orderId, item.id),
            extra: item,
          ),
          child: Ink(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.productName,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.mutedForeground,
                      size: 18,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    Text(
                      'x${item.quantity}',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: itemStatusColor.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        item.status.viLabel,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: itemStatusColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${_formatVnd(item.price)} / phần',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
                if ((item.note ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Ghi chú: ${item.note}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    _formatVnd(lineTotal),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.foregroundLight,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Loading View ─────────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Fake AppBar
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.muted,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
          ),
          const Expanded(
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Error View ───────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      color: AppColors.foregroundLight,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.destructive.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.error_outline_rounded,
                        size: 36,
                        color: AppColors.destructive,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Không thể tải chi tiết',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.mutedForeground,
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('Thử lại'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
