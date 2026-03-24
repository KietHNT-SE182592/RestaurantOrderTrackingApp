import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/utils/jwt_decoder.dart';
import '../../../../di/injection.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../domain/entities/area_entity.dart';
import '../../domain/entities/serve_item_entity.dart';
import '../../domain/entities/table_detail_entity.dart';
import '../cubit/waiter_delivering_cubit.dart';

class WaiterDeliveringPage extends StatelessWidget {
  const WaiterDeliveringPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<WaiterDeliveringCubit>()..load(),
      child: const _WaiterDeliveringView(),
    );
  }
}

class _WaiterDeliveringView extends StatelessWidget {
  const _WaiterDeliveringView();

  Future<void> _onMarkServed(BuildContext context) async {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không xác định được tài khoản đăng nhập hiện tại.'),
        ),
      );
      return;
    }

    final accountId =
        JwtDecoder.extractId(authState.user.accessToken) ?? authState.user.id;

    try {
      await context.read<WaiterDeliveringCubit>().markSelectedAsServed(
        accountId: accountId,
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể cập nhật đã phục vụ: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      bottomNavigationBar:
          BlocBuilder<WaiterDeliveringCubit, WaiterDeliveringState>(
            builder: (context, state) {
              if (state is! WaiterDeliveringLoaded ||
                  state.selectedCount == 0) {
                return const SizedBox.shrink();
              }

              return _ServedFooter(
                selectedCount: state.selectedCount,
                isSubmitting: state.isSubmitting,
                onClear: () =>
                    context.read<WaiterDeliveringCubit>().clearSelection(),
                onSubmit: () => _onMarkServed(context),
              );
            },
          ),
      body: SafeArea(
        child: BlocBuilder<WaiterDeliveringCubit, WaiterDeliveringState>(
          builder: (context, state) {
            if (state is WaiterDeliveringInitial ||
                state is WaiterDeliveringLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }
            if (state is WaiterDeliveringError) {
              return _DeliveringErrorView(message: state.message);
            }
            if (state is WaiterDeliveringLoaded) {
              return RefreshIndicator(
                onRefresh: () =>
                    context.read<WaiterDeliveringCubit>().refresh(),
                color: AppColors.primary,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                  children: [
                    const _ServeFlowSwitcher(isServingTab: false),
                    const SizedBox(height: 12),
                    _DeliveringHeader(totalItems: state.totalDeliveringItems),
                    const SizedBox(height: 12),
                    _AreaFilterChips(
                      selectedAreaId: state.selectedAreaId,
                      onSelect: (id) =>
                          context.read<WaiterDeliveringCubit>().selectArea(id),
                      areas: state.areas,
                    ),
                    const SizedBox(height: 12),
                    _SelectAllRow(
                      value: state.isAllFilteredSelected,
                      enabled:
                          !state.isSubmitting && state.filteredItems.isNotEmpty,
                      selectedCount: state.selectedInFilterCount,
                      totalCount: state.filteredItems.length,
                      onChanged: (value) => context
                          .read<WaiterDeliveringCubit>()
                          .toggleSelectAllForFilteredItems(value),
                    ),
                    const SizedBox(height: 12),
                    if (state.groupedByTable.isEmpty)
                      const _DeliveringEmptyView()
                    else
                      ...state.groupedByTable.values.map(
                        (items) => _TableDeliveringCard(
                          items: items,
                          selectedItemIds: state.selectedItemIds,
                          onToggleItem: (id) => context
                              .read<WaiterDeliveringCubit>()
                              .toggleItemSelection(id),
                          isSubmitting: state.isSubmitting,
                        ),
                      ),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _SelectAllRow extends StatelessWidget {
  final bool value;
  final bool enabled;
  final int selectedCount;
  final int totalCount;
  final ValueChanged<bool> onChanged;

  const _SelectAllRow({
    required this.value,
    required this.enabled,
    required this.selectedCount,
    required this.totalCount,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: enabled ? (v) => onChanged(v ?? false) : null,
            activeColor: AppColors.primary,
            visualDensity: VisualDensity.compact,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              'Chọn tất cả',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: enabled
                    ? AppColors.foregroundLight
                    : AppColors.mutedForeground,
              ),
            ),
          ),
          Text(
            '$selectedCount/$totalCount',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.mutedForeground,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _DeliveringHeader extends StatelessWidget {
  final int totalItems;

  const _DeliveringHeader({required this.totalItems});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 14, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.delivery_dining_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Đang mang ra',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$totalItems món đang mang ra bàn',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.92),
                    fontWeight: FontWeight.w600,
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

class _ServeFlowSwitcher extends StatelessWidget {
  final bool isServingTab;

  const _ServeFlowSwitcher({required this.isServingTab});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: _FlowTabButton(
              label: 'Ra món',
              icon: Icons.restaurant_menu_rounded,
              selected: isServingTab,
              onTap: () {
                if (isServingTab) return;
                context.go(AppRoutes.waiterServe);
              },
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _FlowTabButton(
              label: 'Đang mang ra',
              icon: Icons.delivery_dining_rounded,
              selected: !isServingTab,
              onTap: () {
                if (!isServingTab) return;
                context.go(AppRoutes.waiterDelivering);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FlowTabButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _FlowTabButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: selected ? Colors.white : AppColors.mutedForeground,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: selected ? Colors.white : AppColors.foregroundLight,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AreaFilterChips extends StatelessWidget {
  final String selectedAreaId;
  final List<AreaEntity> areas;
  final ValueChanged<String> onSelect;

  const _AreaFilterChips({
    required this.selectedAreaId,
    required this.areas,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: areas.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            final selected = selectedAreaId.isEmpty;
            return _AreaChip(
              label: 'Tất cả',
              selected: selected,
              onTap: () => onSelect(''),
            );
          }

          final area = areas[index - 1];
          final selected = selectedAreaId == area.id;
          return _AreaChip(
            label: area.name,
            selected: selected,
            onTap: () => onSelect(area.id),
          );
        },
      ),
    );
  }
}

class _AreaChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _AreaChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : Colors.white,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: selected ? Colors.white : AppColors.foregroundLight,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _TableDeliveringCard extends StatelessWidget {
  final List<ServeItemEntity> items;
  final Set<String> selectedItemIds;
  final ValueChanged<String> onToggleItem;
  final bool isSubmitting;

  const _TableDeliveringCard({
    required this.items,
    required this.selectedItemIds,
    required this.onToggleItem,
    required this.isSubmitting,
  });

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

  TableOrderItemSummaryEntity _toDetailItem(ServeItemEntity item) {
    return TableOrderItemSummaryEntity(
      id: item.id,
      orderId: item.orderId,
      productId: item.productId,
      productName: item.productName,
      price: item.productPrice,
      quantity: 1,
      chefAccountId: item.chefAccountId,
      chefName: item.chefName,
      waiterAccountId: item.waiterAccountId,
      waiterName: item.waiterName,
      orderChannel: item.orderChannel,
      note: item.note,
      status: item.status,
      createdAt: item.createdAt,
      updatedAt: item.updatedAt,
    );
  }

  @override
  Widget build(BuildContext context) {
    final first = items.first;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.table_restaurant_rounded,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bàn ${first.tableNumber}',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      Text(
                        first.areaName,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${items.length} món',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...items.map(
            (item) => Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isSubmitting ? null : () => onToggleItem(item.id),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.productName,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              _formatVnd(item.productPrice),
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.mutedForeground),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: selectedItemIds.contains(item.id)
                              ? AppColors.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: selectedItemIds.contains(item.id)
                                ? AppColors.primary
                                : AppColors.border,
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          selectedItemIds.contains(item.id)
                              ? Icons.check_rounded
                              : Icons.add_rounded,
                          size: 16,
                          color: selectedItemIds.contains(item.id)
                              ? Colors.white
                              : AppColors.mutedForeground,
                        ),
                      ),
                      const SizedBox(width: 6),
                      IconButton(
                        tooltip: 'Xem chi tiết món',
                        onPressed: () => context.push(
                          AppRoutes.waiterOrderItemDetailOf(
                            item.orderId,
                            item.id,
                          ),
                          extra: _toDetailItem(item),
                        ),
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServedFooter extends StatelessWidget {
  final int selectedCount;
  final bool isSubmitting;
  final VoidCallback onSubmit;
  final VoidCallback onClear;

  const _ServedFooter({
    required this.selectedCount,
    required this.isSubmitting,
    required this.onSubmit,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: AppColors.border.withValues(alpha: 0.9)),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Đã chọn $selectedCount món',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            TextButton(
              onPressed: isSubmitting ? null : onClear,
              child: const Text('Bỏ chọn'),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed: isSubmitting ? null : onSubmit,
              icon: isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.task_alt_rounded),
              label: Text(isSubmitting ? 'Đang cập nhật...' : 'Đã phục vụ'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeliveringEmptyView extends StatelessWidget {
  const _DeliveringEmptyView();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 38,
            color: AppColors.mutedForeground.withValues(alpha: 0.8),
          ),
          const SizedBox(height: 8),
          Text(
            'Không có món đang mang ra',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Hãy thử chọn khu vực khác hoặc kéo xuống để làm mới.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.mutedForeground),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _DeliveringErrorView extends StatelessWidget {
  final String message;

  const _DeliveringErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 40,
              color: AppColors.destructive,
            ),
            const SizedBox(height: 12),
            Text(
              'Không thể tải danh sách đang mang ra',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.mutedForeground),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.read<WaiterDeliveringCubit>().load(),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}
