import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/network/dio_client.dart';
import '../features/auth/data/datasources/auth_local_datasource.dart';
import '../features/auth/data/datasources/auth_remote_datasource.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/domain/usecases/check_auth_status_usecase.dart';
import '../features/auth/domain/usecases/get_saved_role_usecase.dart';
import '../features/auth/domain/usecases/login_usecase.dart';
import '../features/auth/domain/usecases/logout_usecase.dart';
import '../features/auth/presentation/cubit/auth_cubit.dart';
import '../features/waiter/data/datasources/table_remote_datasource.dart';
import '../features/waiter/data/repositories/table_repository_impl.dart';
import '../features/waiter/domain/repositories/table_repository.dart';
import '../features/waiter/domain/usecases/get_areas_usecase.dart';
import '../features/waiter/domain/usecases/get_table_detail_usecase.dart';
import '../features/waiter/domain/usecases/get_tables_usecase.dart';
import '../features/waiter/presentation/cubit/table_detail_cubit.dart';
import '../features/waiter/presentation/cubit/table_list_cubit.dart';

/// Service Locator toàn cục.
final sl = GetIt.instance;

/// Khởi tạo toàn bộ dependency graph theo thứ tự:
/// External → DataSources → Repositories → UseCases → BLoC/Cubit
Future<void> initDependencies() async {
  // ─── External ───────────────────────────────────────────────────────────────
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => prefs);
  sl.registerLazySingleton<DioClient>(() => DioClient());
  sl.registerLazySingleton<Dio>(() => sl<DioClient>().dio);

  // ─── Auth: DataSources ───────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dio: sl<Dio>()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(prefs: sl<SharedPreferences>()),
  );

  // ─── Auth: Repository (dưới interface, không phải concrete) ──────────────────
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl<AuthRemoteDataSource>(),
      localDataSource: sl<AuthLocalDataSource>(),
    ),
  );

  // ─── Auth: UseCases ──────────────────────────────────────────────────────────
  sl.registerLazySingleton(() => LoginUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => LogoutUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => GetSavedRoleUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => CheckAuthStatusUseCase(sl<AuthRepository>()));

  // ─── Auth: Cubit — Singleton (không phải Factory) ────────────────────────────
  // Phải là singleton vì AppRouter dùng cùng instance với BlocProvider.
  sl.registerLazySingleton(
    () => AuthCubit(
      loginUseCase: sl<LoginUseCase>(),
      logoutUseCase: sl<LogoutUseCase>(),
      checkAuthStatusUseCase: sl<CheckAuthStatusUseCase>(),
    ),
  );

  // ─── Table (Waiter): DataSource ───────────────────────────────────────────────
  sl.registerLazySingleton<TableRemoteDataSource>(
    () => TableRemoteDataSourceImpl(dio: sl<Dio>()),
  );

  // ─── Table (Waiter): Repository ───────────────────────────────────────────────
  sl.registerLazySingleton<TableRepository>(
    () => TableRepositoryImpl(remoteDataSource: sl<TableRemoteDataSource>()),
  );

  // ─── Table (Waiter): UseCases ─────────────────────────────────────────────────
  sl.registerLazySingleton(() => GetAreasUseCase(sl<TableRepository>()));
  sl.registerLazySingleton(() => GetTablesUseCase(sl<TableRepository>()));
  sl.registerLazySingleton(() => GetTableDetailUseCase(sl<TableRepository>()));

  // ─── Table (Waiter): Cubits — Factory (mỗi page tạo instance mới) ─────────────
  sl.registerFactory(
    () => TableListCubit(
      getAreasUseCase: sl<GetAreasUseCase>(),
      getTablesUseCase: sl<GetTablesUseCase>(),
    ),
  );
  sl.registerFactory(
    () => TableDetailCubit(getTableDetailUseCase: sl<GetTableDetailUseCase>()),
  );
}

