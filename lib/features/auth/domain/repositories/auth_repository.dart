import '../entities/user_entity.dart';

/// Contract (interface) của Domain.
/// Data layer implement, Presentation layer consume thông qua UseCase.
/// Domain KHÔNG phụ thuộc vào bất kỳ package hay layer nào khác.
abstract class AuthRepository {
  /// Đăng nhập, trả về [UserEntity] nếu thành công, ném [Failure] nếu thất bại.
  Future<UserEntity> login(String userName, String password);

  /// Xóa token và dữ liệu phiên đăng nhập khỏi local storage.
  Future<void> logout();

  /// Lấy role đã lưu để Router điều hướng khi mở lại app.
  Future<String?> getSavedRole();

  /// Lấy access token đã lưu (dùng để decode JWT khi cold start).
  Future<String?> getAccessToken();
}
