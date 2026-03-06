import '../entities/area_entity.dart';
import '../repositories/table_repository.dart';

class GetAreasUseCase {
  final TableRepository _repository;

  const GetAreasUseCase(this._repository);

  Future<List<AreaEntity>> call() => _repository.getAreas();
}
