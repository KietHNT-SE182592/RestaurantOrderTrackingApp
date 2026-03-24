import '../repositories/table_repository.dart';

class UpdateOrderItemsStatusUseCase {
  final TableRepository repository;

  const UpdateOrderItemsStatusUseCase(this.repository);

  Future<String> call({
    required List<String> orderItemIds,
    required int newStatus,
    required String accountId,
    required String changeSource,
    String? assigneeId,
  }) {
    return repository.updateOrderItemsStatus(
      orderItemIds: orderItemIds,
      newStatus: newStatus,
      accountId: accountId,
      changeSource: changeSource,
      assigneeId: assigneeId,
    );
  }
}
