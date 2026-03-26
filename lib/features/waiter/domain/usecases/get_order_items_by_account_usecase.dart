import '../entities/serve_item_entity.dart';
import '../repositories/table_repository.dart';

class GetOrderItemsByAccountUseCase {
  final TableRepository _repository;

  const GetOrderItemsByAccountUseCase(this._repository);

  Future<List<ServeItemEntity>> call() {
    return _repository.getOrderItemsByAccount();
  }
}
