import 'app.dart';
import 'di/injection.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter/material.dart';

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