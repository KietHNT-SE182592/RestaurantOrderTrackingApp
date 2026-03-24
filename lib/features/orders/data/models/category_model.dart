import '../../domain/entities/category_entity.dart';

class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.id,
    required super.name,
    required super.description,
    required super.imageUrl,
    required super.isActive,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final rawActive = json['isActive'];
    final isActive = rawActive is bool
        ? rawActive
        : rawActive.toString().toLowerCase() == 'true';

    return CategoryModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      isActive: isActive,
    );
  }
}
