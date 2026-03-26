import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/status_enums.dart';
import '../../../../di/injection.dart';
import '../../domain/entities/table_entity.dart';
import '../cubit/table_list_cubit.dart';

class WaiterTablesPage extends StatelessWidget {
  const WaiterTablesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<TableListCubit>()..loadTablesAndAreas(),
      child: const _WaiterTablesView(),
    );
  }
}

class _WaiterTablesView extends StatelessWidget {
  const _WaiterTablesView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const _AreaFilterBar(),
            const SizedBox(height: 8),
            const _StatusDropdownFilter(),
            const Expanded(child: _TableGrid()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.table_restaurant_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sơ đồ Bàn',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.foregroundLight,
                ),
              ),
              BlocBuilder<TableListCubit, TableListState>(
                builder: (context, state) {
                  if (state is TableListLoaded) {
                    final visibleTables = state.filteredTables;
                    final available = visibleTables
                        .where((t) => t.isAvailable)
                        .length;
                    final hasFilters =
                        state.selectedAreaId.isNotEmpty ||
                        state.selectedStatus != null;

                    final subtitle = hasFilters
                        ? '$available / ${visibleTables.length} bàn trống (đã lọc)'
                        : '$available / ${state.tables.length} bàn trống';

                    return Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.mutedForeground,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
          const Spacer(),
          BlocBuilder<TableListCubit, TableListState>(
            builder: (context, state) {
              if (state is TableListLoading) {
                return const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                );
              }
              return IconButton(
                onPressed: () => context.read<TableListCubit>().refresh(),
                icon: const Icon(Icons.refresh_rounded),
                color: AppColors.primary,
                tooltip: 'Làm mới',
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─── Area Filter Bar ──────────────────────────────────────────────────────────

class _AreaFilterBar extends StatelessWidget {
  const _AreaFilterBar();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TableListCubit, TableListState>(
      builder: (context, state) {
        if (state is! TableListLoaded) return const SizedBox.shrink();

        final areas = state.areas;
        final selectedAreaId = state.selectedAreaId;

        return SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _AreaChip(
                label: 'Tất cả',
                isSelected: selectedAreaId.isEmpty,
                onTap: () => context.read<TableListCubit>().selectArea(''),
              ),
              ...areas.map(
                (area) => _AreaChip(
                  label: area.name,
                  isSelected: selectedAreaId == area.id,
                  onTap: () =>
                      context.read<TableListCubit>().selectArea(area.id),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatusDropdownFilter extends StatelessWidget {
  const _StatusDropdownFilter();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TableListCubit, TableListState>(
      builder: (context, state) {
        if (state is! TableListLoaded) return const SizedBox.shrink();

        const filterableStatuses = [
          TableStatus.available,
          TableStatus.reserved,
        ];
        final selectedStatus = state.selectedStatus;
        final effectiveSelectedStatus = filterableStatuses.contains(selectedStatus)
            ? selectedStatus
            : null;
        if (selectedStatus != null && effectiveSelectedStatus == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) return;
            context.read<TableListCubit>().selectStatus(null);
          });
        }
        final totalCount = state.tables.length;
        final statusCounts = {
          for (final status in filterableStatuses)
            status: state.tables
                .where((table) => table.status == status)
                .length,
        };

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Spacer(),
              Container(
                height: 44,
                constraints: const BoxConstraints(minWidth: 180, maxWidth: 230),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border, width: 1.2),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<TableStatus?>(
                    isExpanded: true,
                    value: effectiveSelectedStatus,
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.mutedForeground,
                      size: 20,
                    ),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.foregroundLight,
                      fontWeight: FontWeight.w600,
                    ),
                    selectedItemBuilder: (context) => [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Trạng thái: Tất cả',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: AppColors.foregroundLight,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      ...statusCounts.entries.map(
                        (entry) => Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _statusFilterColor(entry.key),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Trạng thái: ${entry.key.viLabel}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: AppColors.foregroundLight,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    items: [
                      DropdownMenuItem<TableStatus?>(
                        value: null,
                        child: Text('Tất cả ($totalCount)'),
                      ),
                      ...statusCounts.entries.map(
                        (entry) => DropdownMenuItem<TableStatus?>(
                          value: entry.key,
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _statusFilterColor(entry.key),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text('${entry.key.viLabel} (${entry.value})'),
                            ],
                          ),
                        ),
                      ),
                    ],
                    onChanged: (value) =>
                        context.read<TableListCubit>().selectStatus(value),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

Color _statusFilterColor(TableStatus status) {
  switch (status) {
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

class _AreaChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _AreaChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.white : AppColors.foregroundLight,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Table Grid ───────────────────────────────────────────────────────────────

class _TableGrid extends StatelessWidget {
  const _TableGrid();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TableListCubit, TableListState>(
      builder: (context, state) {
        if (state is TableListLoading) return const _LoadingGrid();

        if (state is TableListError) {
          return _ErrorView(
            message: state.message,
            onRetry: () => context.read<TableListCubit>().refresh(),
          );
        }

        if (state is TableListLoaded) {
          final tables = state.filteredTables;
          if (tables.isEmpty) {
            final matchedArea = state.selectedAreaId.isEmpty
                ? null
                : state.areas
                      .where((a) => a.id == state.selectedAreaId)
                      .map((a) => a.name)
                      .firstOrNull;
            final selectedStatusLabel = state.selectedStatus?.viLabel;
            return _EmptyView(
              areaName: matchedArea,
              statusLabel: selectedStatusLabel,
            );
          }

          return RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: Colors.white,
            onRefresh: () => context.read<TableListCubit>().refresh(),
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.05,
              ),
              itemCount: tables.length,
              itemBuilder: (context, index) => _TableCard(table: tables[index]),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

// ─── Table Card ───────────────────────────────────────────────────────────────

class _TableCard extends StatelessWidget {
  final TableEntity table;
  const _TableCard({required this.table});

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

  IconData get _statusIcon {
    switch (table.status) {
      case TableStatus.available:
        return Icons.check_circle_rounded;
      case TableStatus.occupied:
        return Icons.bookmark_rounded;
      case TableStatus.reserved:
        return Icons.people_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await context.push(AppRoutes.waiterTableDetailOf(table.id));
        if (!context.mounted) return;
        await context.read<TableListCubit>().refresh();
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _statusColor.withValues(alpha: 0.35),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: AppColors.mutedForeground,
                  ),
                ],
              ),
              const Spacer(),
              Text(
                table.tableNumber,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.foregroundLight,
                  height: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                table.areaName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.mutedForeground,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_statusIcon, size: 12, color: _statusColor),
                    const SizedBox(width: 4),
                    Text(
                      _statusLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Loading Skeleton Grid ────────────────────────────────────────────────────

class _LoadingGrid extends StatelessWidget {
  const _LoadingGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.05,
      ),
      itemCount: 8,
      itemBuilder: (context, index) => _SkeletonCard(index: index),
    );
  }
}

class _SkeletonCard extends StatefulWidget {
  final int index;
  const _SkeletonCard({required this.index});

  @override
  State<_SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<_SkeletonCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation = Tween(
      begin: 0.4,
      end: 0.9,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => Container(
        decoration: BoxDecoration(
          color: AppColors.muted.withValues(alpha: _animation.value),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

// ─── Empty View ───────────────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  final String? areaName;
  final String? statusLabel;

  const _EmptyView({this.areaName, this.statusLabel});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: AppColors.muted,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.table_restaurant_outlined,
              size: 40,
              color: AppColors.mutedForeground,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _message,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.foregroundLight,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String get _message {
    if (areaName != null && statusLabel != null) {
      return 'Không có bàn "$statusLabel" trong "$areaName"';
    }
    if (areaName != null) {
      return 'Không có bàn trong "$areaName"';
    }
    if (statusLabel != null) {
      return 'Không có bàn "$statusLabel"';
    }
    return 'Không có bàn nào';
  }
}

// ─── Error View ───────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
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
                Icons.wifi_off_rounded,
                size: 36,
                color: AppColors.destructive,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Không thể tải dữ liệu',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.foregroundLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.mutedForeground),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Thử lại'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
