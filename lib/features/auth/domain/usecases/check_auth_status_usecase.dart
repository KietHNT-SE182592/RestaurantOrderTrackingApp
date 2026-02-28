import '../../../../core/utils/jwt_decoder.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// UseCase: Kiểm tra trạng thái xác thực khi mở app (cold start).
///
/// Luồng:
/// 1. Lấy access token đã lưu từ local storage
/// 2. Nếu không có token → return null (chưa đăng nhập)
/// 3. Nếu token hết hạn → return null (cần đăng nhập lại)
/// 4. Decode JWT payload → tạo [UserEntity] từ claims
/// 5. Return [UserEntity] (đang đăng nhập hợp lệ)
class CheckAuthStatusUseCase {
  final AuthRepository _repository;

  const CheckAuthStatusUseCase(this._repository);

  Future<UserEntity?> call() async {
    final token = await _repository.getAccessToken();
    if (token == null || token.isEmpty) return null;
    if (JwtDecoder.isExpired(token)) return null;

    final claims = JwtDecoder.extractUserClaims(token);
    if (claims == null) return null;

    return UserEntity(
      id: claims.id,
      userName: claims.userName,
      fullName: claims.fullName,
      role: claims.role,
      accessToken: token,
      refreshToken: '',
    );
  }
}
