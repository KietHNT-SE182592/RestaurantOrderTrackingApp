import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// UseCase: Thực hiện đăng nhập.
/// Mỗi UseCase = 1 hành động nghiệp vụ duy nhất.
class LoginUseCase {
  final AuthRepository _repository;

  const LoginUseCase(this._repository);

  Future<UserEntity> call(String userName, String password) {
    return _repository.login(userName, password);
  }
}
