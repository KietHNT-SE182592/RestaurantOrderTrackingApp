import '../../../../core/constants/status_enums.dart';

class TableEntity {
  final String id;
  final String tableNumber;
  final String areaName;
  final TableStatus status;

  const TableEntity({
    required this.id,
    required this.tableNumber,
    required this.areaName,
    required this.status,
  });

  bool get isAvailable => status == TableStatus.available;

  bool get isOccupied => status == TableStatus.occupied;

  bool get isReserved => status == TableStatus.reserved;

  int get statusCode => status.apiCode;
}
