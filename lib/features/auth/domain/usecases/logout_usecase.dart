import '../repositories/auth_repository.dart';

/// UseCase: Đăng xuất và xóa phiên.
class LogoutUseCase {
  final AuthRepository _repository;

  const LogoutUseCase(this._repository);

  Future<void> call() {
    return _repository.logout();
  }
}
