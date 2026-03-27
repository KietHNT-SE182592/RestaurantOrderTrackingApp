import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../di/injection.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../chef/domain/entities/chef_member_entity.dart';
import '../../../waiter/domain/entities/serve_item_entity.dart';
import '../cubit/chef_cooking_board_cubit.dart';
import '../cubit/head_chef_board_cubit.dart';

enum _ChefPopupFilter { all, asian, european }

class KitchenDisplayPage extends StatelessWidget {
  const KitchenDisplayPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    final role = authState is AuthSuccess ? authState.user.role : '';

    if (role == 'Chef') {
      return BlocProvider(
        create: (_) => sl<ChefCookingBoardCubit>()..load(),
        child: const _ChefCookingView(),
      );
    }

    return BlocProvider(
      create: (_) => sl<HeadChefBoardCubit>()..load(),
      child: const _HeadChefDisplayView(),
    );
  }
}

class _HeadChefDisplayView extends StatelessWidget {
  const _HeadChefDisplayView();

  String _specialtyLabel(ChefMemberEntity chef) {
    if (chef.isAsianSpecialty) return 'Chuyên món Á';
    if (chef.isEuropeanSpecialty) return 'Chuyên món Âu';
    return 'Đa năng';
  }

  List<ChefMemberEntity> _filterChefs(
    List<ChefMemberEntity> chefs,
    _ChefPopupFilter filter,
  ) {
    switch (filter) {
      case _ChefPopupFilter.asian:
        return chefs.where((chef) => chef.isAsianSpecialty).toList();
      case _ChefPopupFilter.european:
        return chefs.where((chef) => chef.isEuropeanSpecialty).toList();
      case _ChefPopupFilter.all:
        return chefs;
    }
  }

  Future<void> _confirmItem(BuildContext context, String orderItemId) async {
    try {
      await context.read<HeadChefBoardCubit>().confirmOrderItem(orderItemId);
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã xác nhận món.')));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Không thể xác nhận: $e')));
    }
  }

  Future<void> _assignItem(BuildContext context, String orderItemId) async {
    try {
      await context.read<HeadChefBoardCubit>().assignOrderItem(orderItemId);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã phân công và chuyển sang Đang nấu.')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Không thể phân công: $e')));
    }
  }

  Future<void> _showAssignChefDialog(
    BuildContext context, {
    required ServeItemEntity item,
    required List<ChefMemberEntity> chefs,
    required String? selectedAssigneeId,
    required bool isAssigning,
  }) async {
    if (isAssigning) return;
    if (chefs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hiện chưa có đầu bếp khả dụng.')),
      );
      return;
    }

    final selectedChefId = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        var filter = _ChefPopupFilter.all;
        var currentSelected = selectedAssigneeId;

        return StatefulBuilder(
          builder: (context, setState) {
            final filteredChefs = _filterChefs(chefs, filter);
            if (currentSelected != null &&
                filteredChefs.every(
                  (chef) => chef.accountId != currentSelected,
                )) {
              currentSelected = null;
            }

            return AlertDialog(
              title: const Text('Chọn đầu bếp phụ trách'),
              content: SizedBox(
                width: 460,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('Tất cả'),
                          selected: filter == _ChefPopupFilter.all,
                          onSelected: (_) =>
                              setState(() => filter = _ChefPopupFilter.all),
                        ),
                        ChoiceChip(
                          label: const Text('Món Á'),
                          selected: filter == _ChefPopupFilter.asian,
                          onSelected: (_) =>
                              setState(() => filter = _ChefPopupFilter.asian),
                        ),
                        ChoiceChip(
                          label: const Text('Món Âu'),
                          selected: filter == _ChefPopupFilter.european,
                          onSelected: (_) => setState(
                            () => filter = _ChefPopupFilter.european,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (filteredChefs.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'Không có đầu bếp phù hợp với bộ lọc đã chọn.',
                        ),
                      )
                    else
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 280),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: filteredChefs.length,
                          separatorBuilder: (_, _) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final chef = filteredChefs[index];
                            final isSelected =
                                currentSelected == chef.accountId;
                            return ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              selected: isSelected,
                              onTap: () => setState(
                                () => currentSelected = chef.accountId,
                              ),
                              title: Text(chef.fullName),
                              subtitle: Text(_specialtyLabel(chef)),
                              trailing: Icon(
                                isSelected
                                    ? Icons.radio_button_checked_rounded
                                    : Icons.radio_button_unchecked_rounded,
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.mutedForeground,
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Hủy'),
                ),
                FilledButton(
                  onPressed: currentSelected == null
                      ? null
                      : () => Navigator.of(dialogContext).pop(currentSelected),
                  child: const Text('Xác nhận'),
                ),
              ],
            );
          },
        );
      },
    );

    if (!context.mounted || selectedChefId == null || selectedChefId.isEmpty) {
      return;
    }

    context.read<HeadChefBoardCubit>().selectAssignee(
      orderItemId: item.id,
      assigneeId: selectedChefId,
    );
    await _assignItem(context, item.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.foregroundLight,
        title: const Text(
          'KDS Bếp - HeadChef',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Làm mới',
            onPressed: () => context.read<HeadChefBoardCubit>().refresh(),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<HeadChefBoardCubit, HeadChefBoardState>(
          builder: (context, state) {
            if (state is HeadChefBoardInitial ||
                state is HeadChefBoardLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }
            if (state is HeadChefBoardError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: AppColors.destructive,
                        size: 42,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 12),
                      FilledButton.tonal(
                        onPressed: () =>
                            context.read<HeadChefBoardCubit>().load(),
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final data = state as HeadChefBoardLoaded;

            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => context.read<HeadChefBoardCubit>().refresh(),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth < 1000) {
                        return Column(
                          children: [
                            _StatusColumn(
                              title: 'Chờ xác nhận',
                              color: const Color(0xFFB45309),
                              icon: Icons.hourglass_top_rounded,
                              items: data.pendingItems,
                              childBuilder: (item) {
                                return _PendingItemCard(
                                  item: item,
                                  isProcessing: data.processingItemIds.contains(
                                    item.id,
                                  ),
                                  onConfirm: () =>
                                      _confirmItem(context, item.id),
                                );
                              },
                            ),
                            const SizedBox(height: 10),
                            _StatusColumn(
                              title: 'Đã xác nhận',
                              color: const Color(0xFF0F766E),
                              icon: Icons.task_alt_rounded,
                              items: data.confirmedItems,
                              childBuilder: (item) {
                                final selectedAssignee =
                                    data.selectedAssigneesByOrderItem[item.id];
                                return _ConfirmedItemCard(
                                  item: item,
                                  selectedAssigneeId: selectedAssignee,
                                  isProcessing: data.processingItemIds.contains(
                                    item.id,
                                  ),
                                  onTap: () => _showAssignChefDialog(
                                    context,
                                    item: item,
                                    chefs: data.availableChefs,
                                    selectedAssigneeId: selectedAssignee,
                                    isAssigning: data.processingItemIds
                                        .contains(item.id),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 10),
                            _StatusColumn(
                              title: 'Đang nấu',
                              color: AppColors.primary,
                              icon: Icons.local_fire_department_rounded,
                              items: data.cookingItems,
                              childBuilder: (item) =>
                                  _ReadOnlyItemCard(item: item),
                            ),
                            const SizedBox(height: 10),
                            _StatusColumn(
                              title: 'Đã nấu',
                              color: const Color(0xFF15803D),
                              icon: Icons.done_all_rounded,
                              items: data.readyItems,
                              childBuilder: (item) =>
                                  _ReadOnlyItemCard(item: item),
                            ),
                          ],
                        );
                      }

                      return SizedBox(
                        height: MediaQuery.of(context).size.height - 230,
                        child: Row(
                          children: [
                            Expanded(
                              child: _StatusColumn(
                                title: 'Chờ xác nhận',
                                color: const Color(0xFFB45309),
                                icon: Icons.hourglass_top_rounded,
                                items: data.pendingItems,
                                childBuilder: (item) {
                                  return _PendingItemCard(
                                    item: item,
                                    isProcessing: data.processingItemIds
                                        .contains(item.id),
                                    onConfirm: () =>
                                        _confirmItem(context, item.id),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _StatusColumn(
                                title: 'Đã xác nhận',
                                color: const Color(0xFF0F766E),
                                icon: Icons.task_alt_rounded,
                                items: data.confirmedItems,
                                childBuilder: (item) {
                                  final selectedAssignee = data
                                      .selectedAssigneesByOrderItem[item.id];
                                  return _ConfirmedItemCard(
                                    item: item,
                                    selectedAssigneeId: selectedAssignee,
                                    isProcessing: data.processingItemIds
                                        .contains(item.id),
                                    onTap: () => _showAssignChefDialog(
                                      context,
                                      item: item,
                                      chefs: data.availableChefs,
                                      selectedAssigneeId: selectedAssignee,
                                      isAssigning: data.processingItemIds
                                          .contains(item.id),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _StatusColumn(
                                title: 'Đang nấu',
                                color: AppColors.primary,
                                icon: Icons.local_fire_department_rounded,
                                items: data.cookingItems,
                                childBuilder: (item) =>
                                    _ReadOnlyItemCard(item: item),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _StatusColumn(
                                title: 'Đã nấu',
                                color: const Color(0xFF15803D),
                                icon: Icons.done_all_rounded,
                                items: data.readyItems,
                                childBuilder: (item) =>
                                    _ReadOnlyItemCard(item: item),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StatusColumn extends StatelessWidget {
  final String title;
  final Color color;
  final IconData icon;
  final List<ServeItemEntity> items;
  final Widget Function(ServeItemEntity item) childBuilder;

  const _StatusColumn({
    required this.title,
    required this.color,
    required this.icon,
    required this.items,
    required this.childBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$title (${items.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: items.isEmpty
                ? const Center(
                    child: Text(
                      'Không có món nào',
                      style: TextStyle(color: AppColors.mutedForeground),
                    ),
                  )
                : ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) => childBuilder(items[index]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _PendingItemCard extends StatelessWidget {
  final ServeItemEntity item;
  final bool isProcessing;
  final VoidCallback onConfirm;

  const _PendingItemCard({
    required this.item,
    required this.isProcessing,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFFFBEB),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFDE68A)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.productName,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text('Bàn: ${item.tableNumber}'),
            Text('Khu vực: ${item.areaName}'),
            if (item.note?.trim().isNotEmpty == true)
              Text('Ghi chú: ${item.note}')
            else
              const Text('Ghi chú: Không có'),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: isProcessing ? null : onConfirm,
                child: isProcessing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Xác nhận món'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfirmedItemCard extends StatelessWidget {
  final ServeItemEntity item;
  final String? selectedAssigneeId;
  final bool isProcessing;
  final VoidCallback onTap;

  const _ConfirmedItemCard({
    required this.item,
    required this.selectedAssigneeId,
    required this.isProcessing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF0FDFA),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: isProcessing ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF99F6E4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.productName,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text('Bàn: ${item.tableNumber}'),
              Text('Khu vực: ${item.areaName}'),
              if (item.note?.trim().isNotEmpty == true)
                Text('Ghi chú: ${item.note}')
              else
                const Text('Ghi chú: Không có'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      selectedAssigneeId == null
                          ? 'Nhấn để chọn đầu bếp và bắt đầu nấu'
                          : 'Nhấn để đổi đầu bếp',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.mutedForeground,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (isProcessing)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    const Icon(Icons.chevron_right_rounded),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReadOnlyItemCard extends StatelessWidget {
  final ServeItemEntity item;

  const _ReadOnlyItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFFF8FAFC),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.productName,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text('Bàn: ${item.tableNumber}'),
          Text('Khu vực: ${item.areaName}'),
          if (item.note?.trim().isNotEmpty == true) ...[
            Text('Ghi chú: ${item.note}'),
          ] else
            const Text('Ghi chú: Không có'),
        ],
      ),
    );
  }
}

class _ChefCookingView extends StatelessWidget {
  const _ChefCookingView();

  String _formatTime(DateTime? input) {
    if (input == null) return '--:--';
    final local = input.toLocal();
    final h = local.hour.toString().padLeft(2, '0');
    final m = local.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _finishOne(BuildContext context, ChefDishGroup group) async {
    try {
      await context.read<ChefCookingBoardCubit>().finishOneItem(group);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã chuyển 1 món sang sẵn sàng phục vụ.')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Không thể cập nhật: $e')));
    }
  }

  Future<void> _finishAll(BuildContext context, ChefDishGroup group) async {
    try {
      await context.read<ChefCookingBoardCubit>().finishAllItems(group);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã chuyển tất cả món sang sẵn sàng phục vụ.'),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Không thể cập nhật: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.foregroundLight,
        title: const Text(
          'KDS Bếp - Chef',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Làm mới',
            onPressed: () => context.read<ChefCookingBoardCubit>().refresh(),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<ChefCookingBoardCubit, ChefCookingBoardState>(
          builder: (context, state) {
            if (state is ChefCookingBoardInitial ||
                state is ChefCookingBoardLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (state is ChefCookingBoardError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: AppColors.destructive,
                        size: 42,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 12),
                      FilledButton.tonal(
                        onPressed: () =>
                            context.read<ChefCookingBoardCubit>().load(),
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final data = state as ChefCookingBoardLoaded;

            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => context.read<ChefCookingBoardCubit>().refresh(),
              child: data.groups.isEmpty
                  ? ListView(
                      padding: const EdgeInsets.all(24),
                      children: const [
                        SizedBox(height: 120),
                        Icon(
                          Icons.ramen_dining_outlined,
                          size: 52,
                          color: AppColors.mutedForeground,
                        ),
                        SizedBox(height: 10),
                        Center(
                          child: Text(
                            'Hiện không có món nào đang nấu.',
                            style: TextStyle(color: AppColors.mutedForeground),
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
                      itemCount: data.groups.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final group = data.groups[index];
                        final isProcessing = data.isGroupProcessing(group);

                        return _ChefDishGroupCard(
                          group: group,
                          isProcessing: isProcessing,
                          onFinishOne: () => _finishOne(context, group),
                          onFinishAll: () => _finishAll(context, group),
                          formatTime: _formatTime,
                        );
                      },
                    ),
            );
          },
        ),
      ),
    );
  }
}

class _ChefDishGroupCard extends StatefulWidget {
  final ChefDishGroup group;
  final bool isProcessing;
  final VoidCallback onFinishOne;
  final VoidCallback onFinishAll;
  final String Function(DateTime? input) formatTime;

  const _ChefDishGroupCard({
    required this.group,
    required this.isProcessing,
    required this.onFinishOne,
    required this.onFinishAll,
    required this.formatTime,
  });

  @override
  State<_ChefDishGroupCard> createState() => _ChefDishGroupCardState();
}

class _ChefDishGroupCardState extends State<_ChefDishGroupCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final isSingleItem = widget.group.quantity <= 1;
    final singleItem = isSingleItem ? widget.group.oldestItem : null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: isSingleItem
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: isSingleItem ? 0 : 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.group.productName,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Số lượng: ${widget.group.quantity}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.mutedForeground,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (isSingleItem)
                SizedBox(
                  height: 34,
                  child: FilledButton(
                    onPressed: widget.isProcessing ? null : widget.onFinishOne,
                    child: widget.isProcessing
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Xong'),
                  ),
                )
              else
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SizedBox(
                      height: 34,
                      child: OutlinedButton(
                        onPressed: widget.isProcessing
                            ? null
                            : widget.onFinishOne,
                        child: const Text('Xong 1 phần'),
                      ),
                    ),
                    SizedBox(
                      height: 34,
                      child: FilledButton(
                        onPressed: widget.isProcessing
                            ? null
                            : widget.onFinishAll,
                        child: widget.isProcessing
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Xong tất cả'),
                      ),
                    ),
                    IconButton(
                      tooltip: _expanded ? 'Thu gọn chi tiết' : 'Xem chi tiết',
                      onPressed: () => setState(() => _expanded = !_expanded),
                      icon: Icon(
                        _expanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          if (isSingleItem && singleItem != null) ...[
            const SizedBox(height: 8),
            Text('Bàn: ${singleItem.tableNumber}'),
            Text('Khu vực: ${singleItem.areaName}'),
            Text('Giờ vào bếp: ${widget.formatTime(singleItem.createdAt)}'),
            if (singleItem.note?.trim().isNotEmpty == true)
              Text('Ghi chú: ${singleItem.note}')
            else
              const Text('Ghi chú: Không có'),
          ],
          if (_expanded) ...[
            const SizedBox(height: 8),
            ...widget.group.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Bàn: ${item.tableNumber}'),
                      Text('Khu vực: ${item.areaName}'),
                      Text('Giờ vào bếp: ${widget.formatTime(item.createdAt)}'),
                      if (item.note?.trim().isNotEmpty == true)
                        Text('Ghi chú: ${item.note}')
                      else
                        const Text('Ghi chú: Không có'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
