import '../../domain/entities/table_entity.dart';

class TableModel extends TableEntity {
  const TableModel({
    required super.id,
    required super.tableNumber,
    required super.areaName,
    required super.status,
  });

  factory TableModel.fromJson(Map<String, dynamic> json) {
    return TableModel(
      id: json['id'] as String? ?? '',
      tableNumber: json['tableNumber'] as String? ?? '',
      areaName: json['areaName'] as String? ?? '',
      status: json['status'] as String? ?? '',
    );
  }
}
