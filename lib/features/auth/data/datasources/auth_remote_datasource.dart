import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
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
        data: {
          'userName': userName,
          'password': password,
        },
      );

      if (response.data['succeeded'] == true) {
        return UserModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          response.data['message'] ?? 'Đăng nhập thất bại',
        );
      }
    } on DioException catch (e) {
      throw ServerException('Lỗi kết nối máy chủ: ${e.message}');
    }
  }
}
