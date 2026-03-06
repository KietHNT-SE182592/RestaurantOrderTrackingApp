import '../../domain/entities/table_detail_entity.dart';

class TableDetailModel extends TableDetailEntity {
  const TableDetailModel({
    required super.id,
    required super.tableNumber,
    required super.areaName,
    required super.status,
    super.qrCode,
    required super.capacity,
    required super.orders,
  });

  factory TableDetailModel.fromJson(Map<String, dynamic> json) {
    final rawOrders = json['orders'] as List<dynamic>? ?? [];
    return TableDetailModel(
      id: json['id'] as String? ?? '',
      tableNumber: json['tableNumber'] as String? ?? '',
      areaName: json['areaName'] as String? ?? '',
      status: json['status'] as String? ?? '',
      qrCode: json['qrCode'] as String?,
      capacity: json['capacity'] as int? ?? 0,
      orders: rawOrders
          .whereType<Map<String, dynamic>>()
          .toList(),
    );
  }
}
