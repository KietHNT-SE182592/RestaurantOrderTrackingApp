import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../di/injection.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../cubit/order_menu_cubit.dart';
import 'order_cart_page.dart';

class OrderMenuPage extends StatelessWidget {
  final String orderId;

  const OrderMenuPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<OrderMenuCubit>()..initialize(),
      child: _OrderMenuView(orderId: orderId),
    );
  }
}

class _OrderMenuView extends StatelessWidget {
  final String orderId;

  const _OrderMenuView({required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        title: const Text('Gọi món'),
        elevation: 0,
      ),
      body: BlocBuilder<OrderMenuCubit, OrderMenuState>(
        builder: (context, state) {
          if (state.isLoadingInitial) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state.errorMessage != null && state.products.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      state.errorMessage!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: () =>
                          context.read<OrderMenuCubit>().initialize(),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            );
          }

          return _OrderMenuContent(orderId: orderId, state: state);
        },
      ),
      bottomNavigationBar: BlocBuilder<OrderMenuCubit, OrderMenuState>(
        builder: (context, state) {
          final count = state.cartItemsCount;
          final orderLabel = orderId.length >= 6
              ? orderId.substring(0, 6)
              : orderId;
          return SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      count > 0
                          ? 'Đã chọn $count món cho đơn #$orderLabel'
                          : 'Chưa có món nào trong giỏ',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: count > 0
                            ? AppColors.foregroundLight
                            : AppColors.mutedForeground,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  FilledButton(
                    onPressed: count == 0
                        ? null
                        : () {
                            final cubit = context.read<OrderMenuCubit>();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => BlocProvider.value(
                                  value: cubit,
                                  child: OrderCartPage(orderId: orderId),
                                ),
                              ),
                            );
                          },
                    child: const Text('Xem giỏ'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _OrderMenuContent extends StatefulWidget {
  final String orderId;
  final OrderMenuState state;

  const _OrderMenuContent({required this.orderId, required this.state});

  @override
  State<_OrderMenuContent> createState() => _OrderMenuContentState();
}

class _OrderMenuContentState extends State<_OrderMenuContent> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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

  @override
  Widget build(BuildContext context) {
    final grouped = _buildGroupedProducts(
      categories: widget.state.categories,
      products: widget.state.products,
      selectedCategoryName: widget.state.selectedCategoryName,
      searchQuery: _searchQuery,
    );

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.pixels >=
            notification.metrics.maxScrollExtent - 220) {
          context.read<OrderMenuCubit>().loadMoreProducts();
        }
        return false;
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
        children: [
          _ProductSearchField(
            controller: _searchController,
            onChanged: (value) => setState(() => _searchQuery = value),
            onClear: () {
              _searchController.clear();
              setState(() => _searchQuery = '');
            },
          ),
          const SizedBox(height: 12),
          _CategoryFilter(
            categories: widget.state.categories,
            selectedCategoryName: widget.state.selectedCategoryName,
            onSelected: (value) =>
                context.read<OrderMenuCubit>().selectCategory(value),
          ),
          const SizedBox(height: 12),
          if (grouped.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 36),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.no_food_rounded,
                    color: AppColors.mutedForeground,
                    size: 40,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _searchQuery.trim().isNotEmpty
                        ? 'Không tìm thấy món phù hợp với "${_searchQuery.trim()}"'
                        : 'Không có món trong danh mục này',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.mutedForeground,
                    ),
                  ),
                ],
              ),
            )
          else
            ...grouped.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _CategorySection(
                  categoryName: entry.key,
                  products: entry.value,
                  formatVnd: _formatVnd,
                ),
              ),
            ),
          if (widget.state.isLoadingMore)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
          if (!widget.state.hasNextPage && widget.state.products.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 6),
              child: Center(
                child: Text(
                  'Đã hiển thị hết món hiện có',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Map<String, List<ProductEntity>> _buildGroupedProducts({
    required List<CategoryEntity> categories,
    required List<ProductEntity> products,
    required String? selectedCategoryName,
    required String searchQuery,
  }) {
    final orderedKeys = categories.map((item) => item.name).toList();
    final grouped = <String, List<ProductEntity>>{};
    final normalizedQuery = _normalize(searchQuery);

    final filtered = selectedCategoryName == null
        ? products
        : products.where((item) => item.categoryName == selectedCategoryName);

    for (final product in filtered) {
      if (normalizedQuery.isNotEmpty &&
          !_normalize(product.name).contains(normalizedQuery)) {
        continue;
      }
      grouped.putIfAbsent(product.categoryName, () => []).add(product);
    }

    final result = <String, List<ProductEntity>>{};
    for (final key in orderedKeys) {
      if (grouped.containsKey(key)) {
        result[key] = grouped[key]!;
      }
    }

    for (final entry in grouped.entries) {
      result.putIfAbsent(entry.key, () => entry.value);
    }

    return result;
  }

  String _normalize(String value) => value.trim().toLowerCase();
}

class _ProductSearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _ProductSearchField({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Tìm món theo tên...',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                onPressed: onClear,
                icon: const Icon(Icons.close_rounded),
                tooltip: 'Xóa tìm kiếm',
              ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),
      ),
    );
  }
}

class _CategoryFilter extends StatelessWidget {
  final List<CategoryEntity> categories;
  final String? selectedCategoryName;
  final ValueChanged<String?> onSelected;

  const _CategoryFilter({
    required this.categories,
    required this.selectedCategoryName,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: const Text('Tất cả'),
              selected: selectedCategoryName == null,
              onSelected: (_) => onSelected(null),
              selectedColor: AppColors.primary.withValues(alpha: 0.15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: selectedCategoryName == null
                      ? AppColors.primary
                      : AppColors.border,
                ),
              ),
            ),
          ),
          ...categories.map(
            (category) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(category.name),
                selected: selectedCategoryName == category.name,
                onSelected: (_) => onSelected(category.name),
                selectedColor: AppColors.primary.withValues(alpha: 0.15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: selectedCategoryName == category.name
                        ? AppColors.primary
                        : AppColors.border,
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

class _CategorySection extends StatelessWidget {
  final String categoryName;
  final List<ProductEntity> products;
  final String Function(int amount) formatVnd;

  const _CategorySection({
    required this.categoryName,
    required this.products,
    required this.formatVnd,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.restaurant_menu_rounded,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  categoryName,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.foregroundLight,
                  ),
                ),
              ),
              Text(
                '${products.length} món',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.mutedForeground,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ...products.map(
          (product) => _ProductCard(product: product, formatVnd: formatVnd),
        ),
      ],
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductEntity product;
  final String Function(int amount) formatVnd;

  const _ProductCard({required this.product, required this.formatVnd});

  Future<void> _openAddToCartSheet(BuildContext context) async {
    final cubit = context.read<OrderMenuCubit>();
    final existingQty = cubit.quantityOf(product.id);
    final existingNotes = cubit.notesOf(product.id);

    var quantity = existingQty > 0 ? existingQty : 1;
    var notes = List<String>.generate(
      quantity,
      (index) => index < existingNotes.length ? existingNotes[index] : '',
    );

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatVnd(product.price),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _SheetQtyButton(
                        icon: Icons.remove,
                        onTap: () {
                          if (quantity <= 1) return;
                          setModalState(() {
                            quantity -= 1;
                            notes = notes.take(quantity).toList();
                          });
                        },
                      ),
                      SizedBox(
                        width: 44,
                        child: Center(
                          child: Text(
                            '$quantity',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      _SheetQtyButton(
                        icon: Icons.add,
                        onTap: () {
                          setModalState(() {
                            quantity += 1;
                            notes = [...notes, ''];
                          });
                        },
                      ),
                      const Spacer(),
                      Text(
                        formatVnd(product.price * quantity),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(quantity, (index) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: index == quantity - 1 ? 0 : 8),
                      child: TextFormField(
                        initialValue: notes[index],
                        maxLines: 2,
                        onChanged: (value) => notes[index] = value,
                        decoration: InputDecoration(
                          labelText: 'Ghi chú món #${index + 1}',
                          hintText: 'Nhập ghi chú riêng cho món này',
                          filled: true,
                          fillColor: AppColors.backgroundLight,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: AppColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: AppColors.border),
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        cubit.upsertCartItem(
                          product: product,
                          quantity: quantity,
                          notes: notes,
                        );
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('Lưu vào giỏ'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final quantity = context.select<OrderMenuCubit, int>(
      (cubit) => cubit.quantityOf(product.id),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.fastfood_rounded,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.foregroundLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.mutedForeground,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      formatVnd(product.price),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    const Spacer(),
                    FilledButton.icon(
                      onPressed: () => _openAddToCartSheet(context),
                      icon: const Icon(Icons.add_rounded, size: 16),
                      label: Text(quantity > 0 ? 'Thêm ($quantity)' : 'Thêm'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(88, 36),
                        visualDensity: VisualDensity.compact,
                        tapTargetSize: MaterialTapTargetSize.padded,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetQtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _SheetQtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.backgroundLight,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(icon, size: 18, color: AppColors.foregroundLight),
        ),
      ),
    );
  }
}
