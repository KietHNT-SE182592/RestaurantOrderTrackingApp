import '../entities/order_detail_entity.dart';
import '../repositories/orders_repository.dart';

class GetOrderDetailUseCase {
  final OrdersRepository _repository;

  const GetOrderDetailUseCase(this._repository);

  Future<OrderDetailEntity> call(String orderId) =>
      _repository.getOrderDetail(orderId);
}
