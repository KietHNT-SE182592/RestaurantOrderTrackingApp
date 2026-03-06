import '../entities/area_entity.dart';
import '../entities/table_detail_entity.dart';
import '../entities/table_entity.dart';

/// Contract (interface) của Table Domain.
/// Data layer implement, Presentation layer tiêu thụ qua UseCase.
abstract class TableRepository {
  /// Lấy danh sách khu vực (areas).
  Future<List<AreaEntity>> getAreas();

  /// Lấy danh sách bàn với phân trang.
  Future<List<TableEntity>> getTables({
    int pageIndex = 1,
    int pageSize = 100,
  });

  /// Lấy chi tiết một bàn theo [tableId].
  Future<TableDetailEntity> getTableDetail(String tableId);
}
