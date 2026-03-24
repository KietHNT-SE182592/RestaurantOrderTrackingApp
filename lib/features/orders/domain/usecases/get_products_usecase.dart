import '../entities/product_page_entity.dart';
import '../repositories/orders_repository.dart';

class GetProductsUseCase {
  final OrdersRepository _repository;

  const GetProductsUseCase(this._repository);

  Future<ProductPageEntity> call({required int pageIndex, int pageSize = 10}) {
    return _repository.getProducts(pageIndex: pageIndex, pageSize: pageSize);
  }
}
