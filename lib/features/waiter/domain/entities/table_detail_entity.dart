class TableDetailEntity {
  final String id;
  final String tableNumber;
  final String areaName;
  final String status;
  final String? qrCode;
  final int capacity;
  final List<Map<String, dynamic>> orders;

  const TableDetailEntity({
    required this.id,
    required this.tableNumber,
    required this.areaName,
    required this.status,
    this.qrCode,
    required this.capacity,
    required this.orders,
  });

  bool get isAvailable => status == 'Available';
}
