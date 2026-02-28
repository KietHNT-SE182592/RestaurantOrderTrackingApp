import 'dart:convert';

/// Decode JWT token thuần Dart, không cần package ngoài.
///
/// JWT format: [header].[payload].[signature]
/// Chỉ cần base64url decode phần [payload] để đọc claims.
class JwtDecoder {
  JwtDecoder._();

  /// Decode JWT và trả về payload dưới dạng Map.
  /// Ném [FormatException] nếu token không hợp lệ.
  static Map<String, dynamic> decode(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw const FormatException('Token JWT không hợp lệ: sai định dạng');
    }
    final payload = parts[1];
    // base64url → base64 chuẩn (thêm padding '=' nếu thiếu)
    final normalized = base64Url.normalize(payload);
    final decoded = utf8.decode(base64Url.decode(normalized));
    return jsonDecode(decoded) as Map<String, dynamic>;
  }

  /// Lấy giá trị `role` từ JWT.
  /// Trả về null nếu token lỗi hoặc không có field role.
  static String? extractRole(String token) {
    try {
      return decode(token)['role'] as String?;
    } catch (_) {
      return null;
    }
  }

  /// Lấy giá trị `sub` (user id) từ JWT.
  static String? extractId(String token) {
    try {
      return decode(token)['sub'] as String?;
    } catch (_) {
      return null;
    }
  }

  /// Kiểm tra token đã hết hạn chưa (so sánh `exp` với thời gian hiện tại).
  /// Trả về true nếu expired hoặc không đọc được token.
  static bool isExpired(String token) {
    try {
      final payload = decode(token);
      final exp = payload['exp'] as int?;
      if (exp == null) return false;
      final expiry = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      return DateTime.now().isAfter(expiry);
    } catch (_) {
      return true;
    }
  }

  /// Giải mã toàn bộ thông tin user từ JWT payload.
  ///
  /// Payload mẫu:
  /// ```json
  /// {
  ///   "sub": "019c9e1d-...",
  ///   "unique_name": "admin",
  ///   "fullName": "Nguyễn Văn A",
  ///   "role": "Admin",
  ///   "exp": 1772259476
  /// }
  /// ```
  static JwtUserClaims? extractUserClaims(String token) {
    try {
      final payload = decode(token);
      return JwtUserClaims(
        id: payload['sub'] as String? ?? '',
        userName: payload['unique_name'] as String? ?? '',
        fullName: payload['fullName'] as String? ?? '',
        role: payload['role'] as String? ?? '',
      );
    } catch (_) {
      return null;
    }
  }
}

/// Dữ liệu user được đọc trực tiếp từ JWT payload.
class JwtUserClaims {
  final String id;
  final String userName;
  final String fullName;
  final String role;

  const JwtUserClaims({
    required this.id,
    required this.userName,
    required this.fullName,
    required this.role,
  });
}
