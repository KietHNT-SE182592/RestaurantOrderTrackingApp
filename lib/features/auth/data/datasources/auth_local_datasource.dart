import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/errors/exceptions.dart';

abstract class AuthLocalDataSource {
  /// Lưu token và role vào SharedPreferences.
  /// Ném [CacheException] nếu ghi thất bại.
  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required String role,
  });

  /// Xóa tất cả dữ liệu phiên đăng nhập.
  Future<void> clearSession();

  /// Lấy role đã lưu. Trả về null nếu chưa đăng nhập.
  Future<String?> getSavedRole();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences prefs;

  const AuthLocalDataSourceImpl({required this.prefs});

  static const _keyAccessToken = 'accessToken';
  static const _keyRefreshToken = 'refreshToken';
  static const _keyUserRole = 'userRole';

  @override
  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required String role,
  }) async {
    try {
      await prefs.setString(_keyAccessToken, accessToken);
      await prefs.setString(_keyRefreshToken, refreshToken);
      await prefs.setString(_keyUserRole, role);
    } catch (e) {
      throw CacheException('Không thể lưu phiên đăng nhập: $e');
    }
  }

  @override
  Future<void> clearSession() async {
    try {
      await prefs.remove(_keyAccessToken);
      await prefs.remove(_keyRefreshToken);
      await prefs.remove(_keyUserRole);
    } catch (e) {
      throw CacheException('Không thể xóa phiên đăng nhập: $e');
    }
  }

  @override
  Future<String?> getSavedRole() async {
    return prefs.getString(_keyUserRole);
  }
}
