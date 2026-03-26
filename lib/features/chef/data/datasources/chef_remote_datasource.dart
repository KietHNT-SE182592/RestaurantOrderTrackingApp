import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/base_response_decoder.dart';
import '../models/chef_member_model.dart';

abstract class ChefRemoteDataSource {
  Future<List<ChefMemberModel>> getAvailableChefs();
}

class ChefRemoteDataSourceImpl implements ChefRemoteDataSource {
  final Dio dio;

  const ChefRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<ChefMemberModel>> getAvailableChefs() async {
    try {
      final response = await dio.get(ApiConstants.chefsAvailable);
      final payload = response.data;

      final rawList = payload is List<dynamic>
          ? payload
          : BaseResponseDecoder.requireListData(
              BaseResponseDecoder.requireSuccess(
                payload,
                fallbackErrorMessage: 'Khong the tai danh sach dau bep.',
                invalidFormatMessage:
                    'Phan hoi danh sach dau bep khong dung dinh dang.',
              ),
              fallbackErrorMessage: 'Du lieu dau bep khong hop le.',
            );

      return rawList
          .whereType<Map<String, dynamic>>()
          .map(ChefMemberModel.fromJson)
          .where((chef) => chef.isAvailable)
          .toList();
    } on DioException catch (e) {
      throw ServerException(
        BaseResponseDecoder.extractErrorMessage(
          e,
          fallbackMessage: 'Loi ket noi may chu.',
        ),
      );
    }
  }
}
