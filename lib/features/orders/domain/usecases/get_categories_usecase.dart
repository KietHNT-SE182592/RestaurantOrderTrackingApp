import '../entities/category_entity.dart';
import '../repositories/orders_repository.dart';

class GetCategoriesUseCase {
  final OrdersRepository _repository;

  const GetCategoriesUseCase(this._repository);

  Future<List<CategoryEntity>> call() => _repository.getCategories();
}
