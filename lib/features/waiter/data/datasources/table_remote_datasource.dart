import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_request_options.dart';
import '../../../../core/network/base_response_decoder.dart';
import '../models/area_model.dart';
import '../models/serve_item_model.dart';
import '../models/table_detail_model.dart';
import '../models/table_model.dart';

abstract class TableRemoteDataSource {
  Future<List<AreaModel>> getAreas();
  Future<List<TableModel>> getTables({int pageIndex, int pageSize});
  Future<TableDetailModel> getTableDetail(String tableId);
  Future<List<ServeItemModel>> getOrderItemsByStatus({required int status});
  Future<String> updateOrderItemsStatus({
    required List<String> orderItemIds,
    required int newStatus,
    required String accountId,
    required String changeSource,
    String? assigneeId,
  });
  Future<String> createOrder({
    required String tableId,
    required String accountId,
    required int orderType,
  });
}

class TableRemoteDataSourceImpl implements TableRemoteDataSource {
  final Dio dio;

  const TableRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<AreaModel>> getAreas() async {
    try {
      final response = await dio.get(ApiConstants.areas);
      final baseResponse = BaseResponseDecoder.requireSuccess(
        response.data,
        fallbackErrorMessage: 'Không thể tải danh sách khu vực',
        invalidFormatMessage:
            'Phản hồi danh sách khu vực không đúng định dạng.',
      );

      final data = BaseResponseDecoder.requireListData(
        baseResponse,
        fallbackErrorMessage: 'Dữ liệu khu vực không hợp lệ.',
      );
      return data
          .whereType<Map<String, dynamic>>()
          .map(AreaModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw ServerException(
        BaseResponseDecoder.extractErrorMessage(
          e,
          fallbackMessage: 'Lỗi kết nối máy chủ.',
        ),
      );
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
        queryParameters: {'PageIndex': pageIndex, 'PageSize': pageSize},
      );
      final baseResponse = BaseResponseDecoder.requireSuccess(
        response.data,
        fallbackErrorMessage: 'Không thể tải danh sách bàn',
        invalidFormatMessage: 'Phản hồi danh sách bàn không đúng định dạng.',
      );

      final data = BaseResponseDecoder.requireListData(
        baseResponse,
        fallbackErrorMessage: 'Dữ liệu bàn không hợp lệ.',
      );

      return data
          .whereType<Map<String, dynamic>>()
          .map(TableModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw ServerException(
        BaseResponseDecoder.extractErrorMessage(
          e,
          fallbackMessage: 'Lỗi kết nối máy chủ.',
        ),
      );
    }
  }

  @override
  Future<TableDetailModel> getTableDetail(String tableId) async {
    try {
      final response = await dio.get('${ApiConstants.tables}/$tableId');
      final baseResponse = BaseResponseDecoder.requireSuccess(
        response.data,
        fallbackErrorMessage: 'Không thể tải thông tin bàn',
        invalidFormatMessage: 'Phản hồi thông tin bàn không đúng định dạng.',
      );

      final data = BaseResponseDecoder.requireMapData(
        baseResponse,
        fallbackErrorMessage: 'Dữ liệu thông tin bàn không hợp lệ.',
      );

      return TableDetailModel.fromJson(data);
    } on DioException catch (e) {
      throw ServerException(
        BaseResponseDecoder.extractErrorMessage(
          e,
          fallbackMessage: 'Lỗi kết nối máy chủ.',
        ),
      );
    }
  }

  @override
  Future<List<ServeItemModel>> getOrderItemsByStatus({
    required int status,
  }) async {
    try {
      final response = await dio.get(
        '${ApiConstants.orderItems}/status/$status',
      );

      final payload = response.data;
      final rawList = payload is List<dynamic>
          ? payload
          : BaseResponseDecoder.requireListData(
              BaseResponseDecoder.requireSuccess(
                payload,
                fallbackErrorMessage: 'Không thể tải danh sách ra món',
                invalidFormatMessage:
                    'Phản hồi danh sách ra món không đúng định dạng.',
              ),
              fallbackErrorMessage: 'Dữ liệu ra món không hợp lệ.',
            );

      return rawList
          .whereType<Map<String, dynamic>>()
          .map(ServeItemModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw ServerException(
        BaseResponseDecoder.extractErrorMessage(
          e,
          fallbackMessage: 'Lỗi kết nối máy chủ.',
        ),
      );
    }
  }

  @override
  Future<String> createOrder({
    required String tableId,
    required String accountId,
    required int orderType,
  }) async {
    try {
      final response = await dio.post(
        ApiConstants.orders,
        data: {
          'tableId': tableId,
          'accountId': accountId,
          'orderType': orderType,
        },
        options: Options(
          extra: {
            ApiRequestOptions.showSuccessMessage: true,
            ApiRequestOptions.showErrorMessage: true,
          },
        ),
      );

      final baseResponse = BaseResponseDecoder.requireSuccess(
        response.data,
        fallbackErrorMessage: 'Không thể tạo đơn hàng',
        invalidFormatMessage: 'Phản hồi tạo đơn không đúng định dạng.',
      );

      final rawData = baseResponse.data;
      if (rawData is String) {
        return rawData;
      }
      if (rawData is Map<String, dynamic>) {
        return rawData['id'] as String? ?? '';
      }
      throw ServerException('Dữ liệu tạo đơn không hợp lệ.');
    } on DioException catch (e) {
      throw ServerException(
        BaseResponseDecoder.extractErrorMessage(
          e,
          fallbackMessage: 'Lỗi kết nối máy chủ.',
        ),
      );
    }
  }

  @override
  Future<String> updateOrderItemsStatus({
    required List<String> orderItemIds,
    required int newStatus,
    required String accountId,
    required String changeSource,
    String? assigneeId,
  }) async {
    try {
      final response = await dio.put(
        ApiConstants.orderItemsUpdateStatus,
        data: {
          'orderItemIds': orderItemIds,
          'newStatus': newStatus,
          'accountId': accountId,
          'changeSource': changeSource,
          'assigneeId': assigneeId,
        },
        options: Options(
          extra: {
            ApiRequestOptions.showSuccessMessage: true,
            ApiRequestOptions.showErrorMessage: true,
          },
        ),
      );

      final baseResponse = BaseResponseDecoder.requireSuccess(
        response.data,
        fallbackErrorMessage: 'Không thể cập nhật trạng thái món',
        invalidFormatMessage:
            'Phản hồi cập nhật trạng thái không đúng định dạng.',
      );

      return baseResponse.messageOr('Cập nhật trạng thái món thành công.');
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
