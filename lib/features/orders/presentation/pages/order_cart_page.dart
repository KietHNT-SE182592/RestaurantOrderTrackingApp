import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/jwt_decoder.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../cubit/order_menu_cubit.dart';

class OrderCartPage extends StatelessWidget {
  final String orderId;

  const OrderCartPage({super.key, required this.orderId});

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

  Future<void> _submitOrder(BuildContext context, OrderMenuState state) async {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phiên đăng nhập đã hết hạn.')),
      );
      return;
    }

    final createdBy =
        JwtDecoder.extractId(authState.user.accessToken) ?? authState.user.id;
    if (createdBy.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không xác định được tài khoản tạo món.')),
      );
      return;
    }

    if (state.cartItems.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Giỏ hàng đang trống.')));
      return;
    }

    try {
      await context.read<OrderMenuCubit>().submitOrderItems(
        orderId: orderId,
        createdBy: createdBy,
      );
      if (!context.mounted) return;
      Navigator.of(context).pop();
    } on ServerFailure {
      if (!context.mounted) return;
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Không thể gửi gọi món.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        title: const Text('Giỏ hàng'),
        elevation: 0,
      ),
      body: BlocBuilder<OrderMenuCubit, OrderMenuState>(
        builder: (context, state) {
          final cartItems = state.cartItems.values.toList();
          if (cartItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.shopping_cart_outlined,
                    size: 42,
                    color: AppColors.mutedForeground,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Giỏ hàng đang trống',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.mutedForeground,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 110),
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              final item = cartItems[index];

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.product.name,
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatVnd(item.product.price),
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => context
                              .read<OrderMenuCubit>()
                              .removeFromCart(item.cartItemId),
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            color: AppColors.destructive,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'Số lượng: 1',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.mutedForeground),
                        ),
                        const Spacer(),
                        Text(
                          _formatVnd(item.product.price),
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.foregroundLight,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      initialValue: item.note,
                      maxLines: 2,
                      minLines: 1,
                      onChanged: (value) => context
                          .read<OrderMenuCubit>()
                          .updateNote(item.cartItemId, value),
                      decoration: InputDecoration(
                        hintText: 'Ghi chú cho món này',
                        filled: true,
                        fillColor: AppColors.backgroundLight,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
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
                  ],
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BlocBuilder<OrderMenuCubit, OrderMenuState>(
        builder: (context, state) {
          final isDisabled = state.cartItems.isEmpty || state.isSubmitting;
          final totalAmount = state.cartItems.values.fold<int>(
            0,
            (sum, item) => sum + item.product.price,
          );

          return SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        'Tổng cộng',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const Spacer(),
                      Text(
                        _formatVnd(totalAmount),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: isDisabled
                          ? null
                          : () => _submitOrder(context, state),
                      icon: state.isSubmitting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send_rounded),
                      label: Text(
                        state.isSubmitting ? 'Đang gửi...' : 'Gọi món',
                      ),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
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
