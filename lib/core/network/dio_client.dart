import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_message_service.dart';
import 'api_request_options.dart';
import 'base_response.dart';
import '../constants/api_constants.dart';

class DioClient {
  late final Dio _dio;
  final ApiMessageService messageService;

  DioClient({required this.messageService}) {
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
          final payload = response.data;
          final baseResponse = _tryParseBaseResponse(payload);
          if (baseResponse != null) {
            if (!baseResponse.succeeded &&
                _shouldShowError(response.requestOptions)) {
              messageService.showError(
                baseResponse.messageOr('Yêu cầu thất bại.'),
              );
            } else if (baseResponse.succeeded &&
                _shouldShowSuccess(response.requestOptions) &&
                baseResponse.message.isNotEmpty) {
              messageService.showSuccess(baseResponse.message);
            }
          }

          return handler.next(response);
        },
        onError: (DioException e, handler) {
          if (_shouldShowError(e.requestOptions)) {
            final response = _tryParseBaseResponse(e.response?.data);
            final fallback = e.message?.trim();

            messageService.showError(
              response?.messageOr(
                    (fallback != null && fallback.isNotEmpty)
                        ? fallback
                        : 'Không thể kết nối máy chủ.',
                  ) ??
                  ((fallback != null && fallback.isNotEmpty)
                      ? fallback
                      : 'Không thể kết nối máy chủ.'),
            );
          }

          return handler.next(e);
        },
      ),
    );
  }

  Dio get dio => _dio;

  bool _shouldShowSuccess(RequestOptions options) {
    return options.extra[ApiRequestOptions.showSuccessMessage] == true;
  }

  bool _shouldShowError(RequestOptions options) {
    final explicit = options.extra[ApiRequestOptions.showErrorMessage];
    if (explicit is bool) {
      return explicit;
    }

    const mutatingMethods = {'POST', 'PUT', 'PATCH', 'DELETE'};
    return mutatingMethods.contains(options.method.toUpperCase());
  }

  BaseResponse? _tryParseBaseResponse(dynamic payload) {
    try {
      return BaseResponse.fromDynamic(payload);
    } on FormatException {
      return null;
    }
  }
}
