import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/area_model.dart';
import '../models/table_detail_model.dart';
import '../models/table_model.dart';

abstract class TableRemoteDataSource {
  Future<List<AreaModel>> getAreas();
  Future<List<TableModel>> getTables({int pageIndex, int pageSize});
  Future<TableDetailModel> getTableDetail(String tableId);
}

class TableRemoteDataSourceImpl implements TableRemoteDataSource {
  final Dio dio;

  const TableRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<AreaModel>> getAreas() async {
    try {
      final response = await dio.get(ApiConstants.areas);
      if (response.data['succeeded'] == true) {
        final data = response.data['data'] as List<dynamic>;
        return data
            .whereType<Map<String, dynamic>>()
            .map(AreaModel.fromJson)
            .toList();
      } else {
        throw ServerException(
          response.data['message'] ?? 'Không thể tải danh sách khu vực',
        );
      }
    } on DioException catch (e) {
      throw ServerException('Lỗi kết nối máy chủ: ${e.message}');
    }
  }

  @override
  Future<List<TableModel>> getTables({
    int pageIndex = 1,
    int pageSize = 100,
  }) async {
    try {
      final response = await dio.get(
        ApiConstants.tables,
        queryParameters: {
          'PageIndex': pageIndex,
          'PageSize': pageSize,
        },
      );
      if (response.data['succeeded'] == true) {
        final data = response.data['data'] as List<dynamic>;
        return data
            .whereType<Map<String, dynamic>>()
            .map(TableModel.fromJson)
            .toList();
      } else {
        throw ServerException(
          response.data['message'] ?? 'Không thể tải danh sách bàn',
        );
      }
    } on DioException catch (e) {
      throw ServerException('Lỗi kết nối máy chủ: ${e.message}');
    }
  }

  @override
  Future<TableDetailModel> getTableDetail(String tableId) async {
    try {
      final response = await dio.get('${ApiConstants.tables}/$tableId');
      if (response.data['succeeded'] == true) {
        return TableDetailModel.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
      } else {
        throw ServerException(
          response.data['message'] ?? 'Không thể tải thông tin bàn',
        );
      }
    } on DioException catch (e) {
      throw ServerException('Lỗi kết nối máy chủ: ${e.message}');
    }
  }
}
