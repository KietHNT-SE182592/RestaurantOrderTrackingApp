import '../../../../core/constants/status_enums.dart';
import '../../domain/entities/serve_item_entity.dart';

class ServeItemModel extends ServeItemEntity {
  const ServeItemModel({
    required super.id,
    required super.orderId,
    required super.tableId,
    required super.tableNumber,
    required super.areaId,
    required super.areaName,
    required super.productId,
    required super.productName,
    required super.productPrice,
    super.chefAccountId,
    super.chefName,
    super.waiterAccountId,
    super.waiterName,
    super.orderChannel,
    super.note,
    required super.status,
    super.createdAt,
    super.updatedAt,
  });

  static DateTime? _parseDate(dynamic value) {
    final text = value as String?;
    if (text == null || text.trim().isEmpty) return null;
    return DateTime.tryParse(text);
  }

  factory ServeItemModel.fromJson(Map<String, dynamic> json) {
    return ServeItemModel(
      id: json['id'] as String? ?? '',
      orderId: json['orderId'] as String? ?? '',
      tableId: json['tableId'] as String? ?? '',
      tableNumber: json['tableNumber'] as String? ?? '',
      areaId: json['areaId'] as String? ?? '',
      areaName: json['areaName'] as String? ?? '',
      productId: json['productId'] as String? ?? '',
      productName: json['productName'] as String? ?? '',
      productPrice: (json['productPrice'] as num?)?.toInt() ?? 0,
      chefAccountId: json['chefAccountId'] as String?,
      chefName: json['chefName'] as String?,
      waiterAccountId: json['waiterAccountId'] as String?,
      waiterName: json['waiterName'] as String?,
      orderChannel: json['orderChannel'] as String?,
      note: json['note'] as String?,
      status: OrderItemStatus.fromApi(json['status']),
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }
}
