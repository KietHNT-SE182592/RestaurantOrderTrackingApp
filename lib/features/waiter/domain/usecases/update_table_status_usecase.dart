import '../repositories/table_repository.dart';

class UpdateTableStatusUseCase {
  final TableRepository _repository;

  const UpdateTableStatusUseCase(this._repository);

  Future<String> call({required String tableId, required int status}) {
    return _repository.updateTableStatus(tableId: tableId, status: status);
  }
}
