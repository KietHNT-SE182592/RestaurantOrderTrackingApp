import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

/// Implementation của [AuthRepository] (thuộc Data layer).
/// Chỉ nói chuyện với DataSources, convert Exception → Failure.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  const AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<UserEntity> login(String userName, String password) async {
    try {
      final userModel = await remoteDataSource.login(userName, password);
      await localDataSource.saveSession(
        accessToken: userModel.accessToken,
        refreshToken: userModel.refreshToken,
        role: userModel.role,
      );
      return userModel;
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await localDataSource.clearSession();
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    }
  }

  @override
  Future<String?> getSavedRole() {
    return localDataSource.getSavedRole();
  }
}