import '../entities/create_order_item_entity.dart';
import '../repositories/orders_repository.dart';

class CreateOrderItemsUseCase {
  final OrdersRepository _repository;

  const CreateOrderItemsUseCase(this._repository);

  Future<String> call({
    required String orderId,
    required String orderChannel,
    required String createdBy,
    required List<CreateOrderItemEntity> items,
  }) {
    return _repository.createOrderItems(
      orderId: orderId,
      orderChannel: orderChannel,
      createdBy: createdBy,
      items: items,
    );
  }
}
