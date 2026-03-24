import '../../../../core/constants/status_enums.dart';

class TableOrderItemSummaryEntity {
  final String id;
  final String orderId;
  final String productId;
  final String productName;
  final int price;
  final int quantity;
  final String? chefAccountId;
  final String? chefName;
  final String? waiterAccountId;
  final String? waiterName;
  final String? orderChannel;
  final String? note;
  final OrderItemStatus status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const TableOrderItemSummaryEntity({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    this.chefAccountId,
    this.chefName,
    this.waiterAccountId,
    this.waiterName,
    this.orderChannel,
    this.note,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });
}

class TableOrderSummaryEntity {
  final String id;
  final String orderType;
  final OrderStatus status;
  final int totalAmount;
  final List<TableOrderItemSummaryEntity> orderItems;

  const TableOrderSummaryEntity({
    required this.id,
    required this.orderType,
    required this.status,
    required this.totalAmount,
    required this.orderItems,
  });

  int get totalItems => orderItems.fold(0, (sum, item) => sum + item.quantity);
}

class TableDetailEntity {
  final String id;
  final String tableNumber;
  final String areaName;
  final TableStatus status;
  final String? qrCode;
  final int capacity;
  final TableOrderSummaryEntity? activeOrder;

  const TableDetailEntity({
    required this.id,
    required this.tableNumber,
    required this.areaName,
    required this.status,
    this.qrCode,
    required this.capacity,
    required this.activeOrder,
  });

  bool get isAvailable => status == TableStatus.available;

  bool get hasActiveOrder => activeOrder != null;

  int get statusCode => status.apiCode;
}
