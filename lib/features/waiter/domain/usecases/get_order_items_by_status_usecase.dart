import '../entities/serve_item_entity.dart';
import '../repositories/table_repository.dart';

class GetOrderItemsByStatusUseCase {
  final TableRepository _repository;

  const GetOrderItemsByStatusUseCase(this._repository);

  Future<List<ServeItemEntity>> call(int status) {
    return _repository.getOrderItemsByStatus(status: status);
  }
}
