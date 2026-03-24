import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/constants/app_colors.dart';
import 'core/shared_features/widgets/api_feedback_listener.dart';
import 'di/injection.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'routes/app_router.dart';

class RestaurantApp extends StatelessWidget {
  const RestaurantApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Lấy singleton đã khởi tạo sẵn từ GetIt — không tạo mới
    final authCubit = sl<AuthCubit>();
    final router = AppRouter.createRouter(authCubit);

    return BlocProvider.value(
      value: authCubit,
      child: MaterialApp.router(
        title: 'Restaurant Order Tracking',
        routerConfig: router,
        builder: (context, child) => ApiFeedbackListener(
          messageService: sl(),
          child: child ?? const SizedBox.shrink(),
        ),
        theme: ThemeData(
          scaffoldBackgroundColor: AppColors.backgroundLight,
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
