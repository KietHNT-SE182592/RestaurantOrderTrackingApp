import '../entities/category_entity.dart';
import '../entities/create_order_item_entity.dart';
import '../entities/order_detail_entity.dart';
import '../entities/product_page_entity.dart';

abstract class OrdersRepository {
  Future<OrderDetailEntity> getOrderDetail(String orderId);
  Future<List<CategoryEntity>> getCategories();
  Future<ProductPageEntity> getProducts({required int pageIndex, int pageSize});
  Future<String> createOrderItems({
    required String orderId,
    required String orderChannel,
    required String createdBy,
    required List<CreateOrderItemEntity> items,
  });
}
