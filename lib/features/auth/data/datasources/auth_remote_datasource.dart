import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_request_options.dart';
import '../../../../core/network/base_response_decoder.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  /// Gọi API đăng nhập, trả về [UserModel].
  /// Ném [ServerException] nếu API lỗi hoặc mất mạng.
  Future<UserModel> login(String userName, String password);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  const AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<UserModel> login(String userName, String password) async {
    try {
      final response = await dio.post(
        ApiConstants.login,
        data: {'userName': userName, 'password': password},
        options: Options(
          extra: {
            ApiRequestOptions.showSuccessMessage: false,
            ApiRequestOptions.showErrorMessage: false,
          },
        ),
      );

      final baseResponse = BaseResponseDecoder.requireSuccess(
        response.data,
        fallbackErrorMessage: 'Đăng nhập thất bại',
        invalidFormatMessage: 'Phản hồi đăng nhập không đúng định dạng.',
      );

      final data = BaseResponseDecoder.requireMapData(
        baseResponse,
        fallbackErrorMessage: 'Dữ liệu đăng nhập không hợp lệ.',
      );

      return UserModel.fromJson(data);
    } on DioException catch (e) {
      throw ServerException(
        BaseResponseDecoder.extractErrorMessage(
          e,
          fallbackMessage: 'Lỗi kết nối máy chủ.',
        ),
      );
    }
  }
}
