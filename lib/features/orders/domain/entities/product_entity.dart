class ProductEntity {
  final String id;
  final String name;
  final String description;
  final int price;
  final String? imageUrl;
  final String categoryName;
  final bool isActive;

  const ProductEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.categoryName,
    required this.isActive,
  });
}
