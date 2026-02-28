import '../repositories/auth_repository.dart';

/// UseCase: Lấy role đã lưu từ local storage (dùng khi cold start app).
class GetSavedRoleUseCase {
  final AuthRepository _repository;

  const GetSavedRoleUseCase(this._repository);

  Future<String?> call() {
    return _repository.getSavedRole();
  }
}
