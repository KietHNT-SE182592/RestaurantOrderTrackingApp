import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';

class DioClient {
  late final Dio _dio;

  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        responseType: ResponseType.json,
      ),
    );

    // Thêm Interceptor để tự động gắn Token vào Header
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // TODO: Lấy token từ SharedPreferences hoặc SecureStorage
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('accessToken');
          
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          // Có thể log response ra console ở đây để dễ debug
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          // Xử lý lỗi chung (VD: 401 thì gọi hàm logout)
          return handler.next(e);
        },
      ),
    );
  }

  Dio get dio => _dio;
}