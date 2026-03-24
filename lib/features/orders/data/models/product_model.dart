import '../../domain/entities/product_entity.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.name,
    required super.description,
    required super.price,
    required super.imageUrl,
    required super.categoryName,
    required super.isActive,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final rawActive = json['isActive'];
    final isActive = rawActive is bool
        ? rawActive
        : rawActive.toString().toLowerCase() == 'true';

    return ProductModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toInt() ?? 0,
      imageUrl: json['imageUrl'] as String?,
      categoryName: json['categoryName'] as String? ?? '',
      isActive: isActive,
    );
  }
}
