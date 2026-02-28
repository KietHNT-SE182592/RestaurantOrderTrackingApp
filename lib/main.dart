import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/constants/app_colors.dart';
import 'di/injection.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo toàn bộ dependency graph
  await initDependencies();

  // Lấy singleton AuthCubit đã được wire bởi GetIt
  final authCubit = sl<AuthCubit>();

  // Decode JWT đã lưu để khôi phục session (không cần gọi API)
  await authCubit.checkAuthStatus();

  runApp(RestaurantApp(authCubit: authCubit));
}

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