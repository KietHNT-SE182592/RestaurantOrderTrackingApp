import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/constants/app_colors.dart';
import 'di/injection.dart';
import 'features/auth/domain/usecases/get_saved_role_usecase.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo toàn bộ dependency graph
  await initDependencies();

  // Lấy role đã lưu thông qua UseCase (không còn phụ thuộc thẳng vào Data)
  final savedRole = await sl<GetSavedRoleUseCase>()();

  runApp(RestaurantApp(initialRole: savedRole));
}

class RestaurantApp extends StatelessWidget {
  final String? initialRole;

  const RestaurantApp({super.key, this.initialRole});

  @override
  Widget build(BuildContext context) {
    final router = AppRouter.createRouter(initialRole);

    return MultiBlocProvider(
      providers: [
        // sl<AuthCubit>() dùng registerFactory nên mỗi lần là instance mới
        BlocProvider(create: (_) => sl<AuthCubit>()),
      ],
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