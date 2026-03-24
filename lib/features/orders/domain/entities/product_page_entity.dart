import 'product_entity.dart';

class ProductPageEntity {
  final List<ProductEntity> products;
  final int pageNumber;
  final int pageSize;
  final int totalPages;
  final int totalRecords;
  final bool hasPreviousPage;
  final bool hasNextPage;

  const ProductPageEntity({
    required this.products,
    required this.pageNumber,
    required this.pageSize,
    required this.totalPages,
    required this.totalRecords,
    required this.hasPreviousPage,
    required this.hasNextPage,
  });
}
