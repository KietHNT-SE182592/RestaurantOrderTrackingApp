import '../entities/table_entity.dart';
import '../repositories/table_repository.dart';

class GetTablesUseCase {
  final TableRepository _repository;

  const GetTablesUseCase(this._repository);

  Future<List<TableEntity>> call({
    int pageIndex = 1,
    int pageSize = 100,
  }) =>
      _repository.getTables(pageIndex: pageIndex, pageSize: pageSize);
}
