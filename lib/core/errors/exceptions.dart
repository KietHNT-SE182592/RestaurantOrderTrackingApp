/// Ném ra khi API trả về lỗi hoặc mất kết nối mạng.
class ServerException implements Exception {
  final String message;
  const ServerException(this.message);

  @override
  String toString() => 'ServerException: $message';
}

/// Ném ra khi đọc/ghi cache (SharedPreferences, Hive...) thất bại.
class CacheException implements Exception {
  final String message;
  const CacheException(this.message);

  @override
  String toString() => 'CacheException: $message';
}
