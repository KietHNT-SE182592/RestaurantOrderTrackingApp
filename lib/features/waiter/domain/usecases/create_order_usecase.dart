import '../repositories/table_repository.dart';

class CreateOrderUseCase {
  final TableRepository _repository;

  const CreateOrderUseCase(this._repository);

  Future<String> call({
    required String tableId,
    required String accountId,
    int orderType = 0,
  }) {
    return _repository.createOrder(
      tableId: tableId,
      accountId: accountId,
      orderType: orderType,
    );
  }
}
