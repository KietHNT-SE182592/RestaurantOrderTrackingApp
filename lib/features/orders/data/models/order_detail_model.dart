import '../../../../core/constants/status_enums.dart';
import '../../domain/entities/order_detail_entity.dart';

DateTime? _parseDate(dynamic raw) {
  if (raw == null) return null;
  return DateTime.tryParse(raw.toString());
}

class OrderItemModel extends OrderItemEntity {
  const OrderItemModel({
    required super.id,
    required super.orderId,
    required super.productId,
    required super.productName,
    required super.productPrice,
    super.chefAccountId,
    super.chefName,
    super.waiterAccountId,
    super.waiterName,
    required super.orderChannel,
    super.note,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] as String? ?? '',
      orderId: json['orderId'] as String? ?? '',
      productId: json['productId'] as String? ?? '',
      productName: json['productName'] as String? ?? '',
      productPrice: (json['productPrice'] as num?)?.toInt() ?? 0,
      chefAccountId: json['chefAccountId'] as String?,
      chefName: json['chefName'] as String?,
      waiterAccountId: json['waiterAccountId'] as String?,
      waiterName: json['waiterName'] as String?,
      orderChannel: json['orderChannel'] as String? ?? '',
      note: json['note'] as String?,
      status: OrderItemStatus.fromApi(json['status']),
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }
}

class OrderDetailModel extends OrderDetailEntity {
  const OrderDetailModel({
    required super.id,
    required super.tableId,
    required super.tableNumber,
    required super.orderType,
    required super.status,
    required super.waiterId,
    required super.waiterName,
    required super.customerId,
    required super.customerName,
    required super.createdAt,
    required super.updatedAt,
    required super.orderItems,
  });

  factory OrderDetailModel.fromJson(Map<String, dynamic> json) {
    final rawItems = (json['orderItems'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();

    return OrderDetailModel(
      id: json['id'] as String? ?? '',
      tableId: json['tableId'] as String? ?? '',
      tableNumber: json['tableNumber'] as String? ?? '',
      orderType: json['orderType'] as String? ?? '',
      status: OrderStatus.fromApi(json['status']),
      waiterId: json['waiterId'] as String? ?? '',
      waiterName: json['waiterName'] as String?,
      customerId: json['customerId'] as String?,
      customerName: json['customerName'] as String?,
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
      orderItems: rawItems.map(OrderItemModel.fromJson).toList(),
    );
  }
}
