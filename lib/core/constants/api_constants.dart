import 'package:flutter/foundation.dart';

class ApiConstants {
  // Ưu tiên nhận từ --dart-define=BASE_URL=...
  // Nếu không có, Android emulator dùng 10.0.2.2 thay vì localhost.
  static const String _baseUrlFromEnv = String.fromEnvironment('BASE_URL');

  static String get baseUrl {
    if (_baseUrlFromEnv.isNotEmpty) {
      return _baseUrlFromEnv;
    }

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:5015/api';
    }

    return 'http://localhost:5015/api';
  }

  // Endpoints
  static const String login = '/Auth/login';
  static const String areas = '/Area';
  static const String tables = '/Table';
  static const String tablesUpdateStatus = '/Table/update-status';
  static const String orders = '/Order';
  static const String orderItems = '/OrderItem';
  static const String orderItemsUpdateStatus = '/OrderItem/Update-Status';
  static const String categories = '/Category';
  static const String products = '/Product';
}
