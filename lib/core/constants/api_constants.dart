class ApiConstants {
  // Đổi localhost thành IP của máy Mac nếu test trên điện thoại thật
  static const String baseUrl = 'http://localhost:5015/api';

  // Endpoints
  static const String login = '/Auth/login';
  static const String areas = '/Area';
  static const String tables = '/Table';
  static const String orders = '/Order';
  static const String orderItems = '/OrderItem';
  static const String orderItemsUpdateStatus = '/OrderItem/Update-Status';
  static const String categories = '/Category';
  static const String products = '/Product';
}
