import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/constants/app_colors.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'routes/app_router.dart';

class RestaurantApp extends StatelessWidget {
  final AuthCubit authCubit;

  const RestaurantApp({super.key, required this.authCubit});

  @override
  Widget build(BuildContext context) {
    // Router nhận cùng singleton authCubit để refreshListenable hoạt động đúng
    final router = AppRouter.createRouter(authCubit);

    return BlocProvider.value(
      // .value — không tạo mới, dùng instance đã tồn tại từ GetIt
      value: authCubit,
      child: MaterialApp.router(
        title: 'Restaurant Order Tracking',
        routerConfig: router,
        theme: ThemeData(
          scaffoldBackgroundColor: AppColors.backgroundLight,
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
