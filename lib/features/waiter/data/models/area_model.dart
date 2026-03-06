import '../../domain/entities/area_entity.dart';

class AreaModel extends AreaEntity {
  const AreaModel({
    required super.id,
    required super.name,
    required super.description,
  });

  factory AreaModel.fromJson(Map<String, dynamic> json) {
    return AreaModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }
}
