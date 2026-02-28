import 'package:flutter/material.dart';

import 'app.dart';
import 'di/injection.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  await sl<AuthCubit>().checkAuthStatus();
  runApp(const RestaurantApp());
}