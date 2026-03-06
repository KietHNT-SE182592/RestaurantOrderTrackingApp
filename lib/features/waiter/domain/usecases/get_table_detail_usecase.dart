import '../entities/table_detail_entity.dart';
import '../repositories/table_repository.dart';

class GetTableDetailUseCase {
  final TableRepository _repository;

  const GetTableDetailUseCase(this._repository);

  Future<TableDetailEntity> call(String tableId) =>
      _repository.getTableDetail(tableId);
}
