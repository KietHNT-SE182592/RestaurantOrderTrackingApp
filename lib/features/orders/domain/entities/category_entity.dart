class CategoryEntity {
  final int id;
  final String name;
  final String description;
  final String? imageUrl;
  final bool isActive;

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.isActive,
  });
}
