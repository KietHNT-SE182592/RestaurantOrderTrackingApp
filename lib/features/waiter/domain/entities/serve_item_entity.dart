import '../../../../core/constants/status_enums.dart';

class ServeItemEntity {
  final String id;
  final String orderId;
  final String tableId;
  final String tableNumber;
  final String areaId;
  final String areaName;
  final String productId;
  final String productName;
  final int productPrice;
  final String? chefAccountId;
  final String? chefName;
  final String? waiterAccountId;
  final String? waiterName;
  final String? orderChannel;
  final String? note;
  final OrderItemStatus status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ServeItemEntity({
    required this.id,
    required this.orderId,
    required this.tableId,
    required this.tableNumber,
    required this.areaId,
    required this.areaName,
    required this.productId,
    required this.productName,
    required this.productPrice,
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
