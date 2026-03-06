class TableEntity {
  final String id;
  final String tableNumber;
  final String areaName;
  final String status;

  const TableEntity({
    required this.id,
    required this.tableNumber,
    required this.areaName,
    required this.status,
  });

  bool get isAvailable => status == 'Available';
}
