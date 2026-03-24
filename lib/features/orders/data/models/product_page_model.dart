import '../../domain/entities/product_page_entity.dart';
import 'product_model.dart';

class ProductPageModel extends ProductPageEntity {
  const ProductPageModel({
    required super.products,
    required super.pageNumber,
    required super.pageSize,
    required super.totalPages,
    required super.totalRecords,
    required super.hasPreviousPage,
    required super.hasNextPage,
  });

  factory ProductPageModel.fromJson(Map<String, dynamic> json) {
    final items = (json['data'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(ProductModel.fromJson)
        .toList();

    final pagination =
        ((json['meta'] as Map<String, dynamic>?)?['pagination']
            as Map<String, dynamic>?) ??
        const <String, dynamic>{};

    return ProductPageModel(
      products: items,
      pageNumber: (pagination['pageNumber'] as num?)?.toInt() ?? 1,
      pageSize: (pagination['pageSize'] as num?)?.toInt() ?? 10,
      totalPages: (pagination['totalPages'] as num?)?.toInt() ?? 1,
      totalRecords:
          (pagination['totalRecords'] as num?)?.toInt() ?? items.length,
      hasPreviousPage: pagination['hasPreviousPage'] as bool? ?? false,
      hasNextPage: pagination['hasNextPage'] as bool? ?? false,
    );
  }
}
