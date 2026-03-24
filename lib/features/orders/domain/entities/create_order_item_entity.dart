class CreateOrderItemEntity {
  final String productId;
  final String note;
  final int quantity;

  const CreateOrderItemEntity({
    required this.productId,
    required this.note,
    required this.quantity,
  });
}
