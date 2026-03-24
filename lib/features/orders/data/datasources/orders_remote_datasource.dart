import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_request_options.dart';
import '../../../../core/network/base_response_decoder.dart';
import '../../domain/entities/create_order_item_entity.dart';
import '../models/category_model.dart';
import '../models/order_detail_model.dart';
import '../models/product_page_model.dart';

abstract class OrdersRemoteDataSource {
  Future<OrderDetailModel> getOrderDetail(String orderId);
  Future<List<CategoryModel>> getCategories();
  Future<ProductPageModel> getProducts({required int pageIndex, int pageSize});
  Future<String> createOrderItems({
    required String orderId,
    required String orderChannel,
    required String createdBy,
    required List<CreateOrderItemEntity> items,
  });
}

class OrdersRemoteDataSourceImpl implements OrdersRemoteDataSource {
  final Dio dio;

  const OrdersRemoteDataSourceImpl({required this.dio});

  @override
  Future<OrderDetailModel> getOrderDetail(String orderId) async {
    try {
      final response = await dio.get('${ApiConstants.orders}/$orderId');
      final baseResponse = BaseResponseDecoder.requireSuccess(
        response.data,
        fallbackErrorMessage: 'Không thể tải chi tiết đơn hàng',
        invalidFormatMessage:
            'Phản hồi chi tiết đơn hàng không đúng định dạng.',
      );

      final data = BaseResponseDecoder.requireMapData(
        baseResponse,
        fallbackErrorMessage: 'Dữ liệu chi tiết đơn hàng không hợp lệ.',
      );
      return OrderDetailModel.fromJson(data);
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
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await dio.get(ApiConstants.categories);
      final baseResponse = BaseResponseDecoder.requireSuccess(
        response.data,
        fallbackErrorMessage: 'Không thể tải danh sách danh mục',
        invalidFormatMessage: 'Phản hồi danh mục không đúng định dạng.',
      );
      final data = BaseResponseDecoder.requireListData(
        baseResponse,
        fallbackErrorMessage: 'Dữ liệu danh mục không hợp lệ.',
      );

      return data
          .whereType<Map<String, dynamic>>()
          .map(CategoryModel.fromJson)
          .where((item) => item.isActive)
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
  Future<ProductPageModel> getProducts({
    required int pageIndex,
    int pageSize = 10,
  }) async {
    try {
      final response = await dio.get(
        ApiConstants.products,
        queryParameters: {'pageIndex': pageIndex, 'pageSize': pageSize},
      );

      final baseResponse = BaseResponseDecoder.requireSuccess(
        response.data,
        fallbackErrorMessage: 'Không thể tải danh sách món ăn',
        invalidFormatMessage: 'Phản hồi danh sách món không đúng định dạng.',
      );

      final data = BaseResponseDecoder.requireListData(
        baseResponse,
        fallbackErrorMessage: 'Dữ liệu món ăn không hợp lệ.',
      );

      return ProductPageModel.fromJson({
        'data': data,
        'meta': baseResponse.meta ?? const <String, dynamic>{},
      });
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
  Future<String> createOrderItems({
    required String orderId,
    required String orderChannel,
    required String createdBy,
    required List<CreateOrderItemEntity> items,
  }) async {
    try {
      final response = await dio.post(
        ApiConstants.orderItems,
        data: {
          'orderId': orderId,
          'orderChannel': orderChannel,
          'createdBy': createdBy,
          'items': items
              .map(
                (item) => {
                  'productId': item.productId,
                  'note': item.note,
                  'quantity': item.quantity,
                },
              )
              .toList(),
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
        fallbackErrorMessage: 'Không thể gọi món',
        invalidFormatMessage: 'Phản hồi gọi món không đúng định dạng.',
      );
      return baseResponse.messageOr('Gọi món thành công.');
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
