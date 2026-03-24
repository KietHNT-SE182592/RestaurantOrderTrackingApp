import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/create_order_item_entity.dart';
import '../../domain/entities/order_detail_entity.dart';
import '../../domain/entities/product_page_entity.dart';
import '../../domain/repositories/orders_repository.dart';
import '../datasources/orders_remote_datasource.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  final OrdersRemoteDataSource remoteDataSource;

  const OrdersRepositoryImpl({required this.remoteDataSource});

  @override
  Future<OrderDetailEntity> getOrderDetail(String orderId) async {
    try {
      return await remoteDataSource.getOrderDetail(orderId);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<List<CategoryEntity>> getCategories() async {
    try {
      return await remoteDataSource.getCategories();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<ProductPageEntity> getProducts({
    required int pageIndex,
    int pageSize = 10,
  }) async {
    try {
      return await remoteDataSource.getProducts(
        pageIndex: pageIndex,
        pageSize: pageSize,
      );
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
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
      return await remoteDataSource.createOrderItems(
        orderId: orderId,
        orderChannel: orderChannel,
        createdBy: createdBy,
        items: items,
      );
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }
}
