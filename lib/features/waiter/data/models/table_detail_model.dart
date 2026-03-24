import '../../../../core/constants/status_enums.dart';
import '../../domain/entities/table_detail_entity.dart';

class TableOrderItemSummaryModel extends TableOrderItemSummaryEntity {
  const TableOrderItemSummaryModel({
    required super.id,
    required super.orderId,
    required super.productId,
    required super.productName,
    required super.price,
    required super.quantity,
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

  factory TableOrderItemSummaryModel.fromJson(Map<String, dynamic> json) {
    final parsedQuantity = (json['quantity'] as num?)?.toInt() ?? 1;
    return TableOrderItemSummaryModel(
      id: json['id'] as String? ?? '',
      orderId: json['orderId'] as String? ?? '',
      productId: json['productId'] as String? ?? '',
      productName: json['productName'] as String? ?? '',
      price:
          (json['price'] as num?)?.toInt() ??
          (json['productPrice'] as num?)?.toInt() ??
          0,
      quantity: parsedQuantity < 1 ? 1 : parsedQuantity,
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

class TableOrderSummaryModel extends TableOrderSummaryEntity {
  const TableOrderSummaryModel({
    required super.id,
    required super.orderType,
    required super.status,
    required super.totalAmount,
    required super.orderItems,
  });

  factory TableOrderSummaryModel.fromJson(Map<String, dynamic> json) {
    final rawItems = (json['orderItems'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();

    return TableOrderSummaryModel(
      id: json['id'] as String? ?? '',
      orderType: json['orderType'] as String? ?? '',
      status: OrderStatus.fromApi(json['status']),
      totalAmount: (json['totalAmount'] as num?)?.toInt() ?? 0,
      orderItems: rawItems.map(TableOrderItemSummaryModel.fromJson).toList(),
    );
  }
}

class TableDetailModel extends TableDetailEntity {
  const TableDetailModel({
    required super.id,
    required super.tableNumber,
    required super.areaName,
    required super.status,
    super.qrCode,
    required super.capacity,
    required super.activeOrder,
  });

  factory TableDetailModel.fromJson(Map<String, dynamic> json) {
    final rawOrder =
        (json['Orders'] ?? json['orders']) as Map<String, dynamic>?;

    return TableDetailModel(
      id: json['id'] as String? ?? '',
      tableNumber: json['tableNumber'] as String? ?? '',
      areaName: json['areaName'] as String? ?? '',
      status: TableStatus.fromApi(json['status']),
      qrCode: json['qrCode'] as String?,
      capacity: (json['capacity'] as num?)?.toInt() ?? 0,
      activeOrder: rawOrder == null
          ? null
          : TableOrderSummaryModel.fromJson(rawOrder),
    );
  }
}
