import '../../../../core/constants/status_enums.dart';

class OrderItemEntity {
  final String id;
  final String orderId;
  final String productId;
  final String productName;
  final int productPrice;
  final String? chefAccountId;
  final String? chefName;
  final String? waiterAccountId;
  final String? waiterName;
  final String orderChannel;
  final String? note;
  final OrderItemStatus status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const OrderItemEntity({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.productPrice,
    this.chefAccountId,
    this.chefName,
    this.waiterAccountId,
    this.waiterName,
    required this.orderChannel,
    this.note,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });
}

class OrderDetailEntity {
  final String id;
  final String tableId;
  final String tableNumber;
  final String orderType;
  final OrderStatus status;
  final String waiterId;
  final String? waiterName;
  final String? customerId;
  final String? customerName;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<OrderItemEntity> orderItems;

  const OrderDetailEntity({
    required this.id,
    required this.tableId,
    required this.tableNumber,
    required this.orderType,
    required this.status,
    required this.waiterId,
    required this.waiterName,
    required this.customerId,
    required this.customerName,
    required this.createdAt,
    required this.updatedAt,
    required this.orderItems,
  });

  int get totalAmount =>
      orderItems.fold(0, (sum, item) => sum + item.productPrice);

  int get totalItems => orderItems.length;
}
