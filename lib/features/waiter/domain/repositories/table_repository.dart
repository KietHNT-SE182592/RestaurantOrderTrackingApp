import '../entities/area_entity.dart';
import '../entities/serve_item_entity.dart';
import '../entities/table_detail_entity.dart';
import '../entities/table_entity.dart';

/// Contract (interface) của Table Domain.
/// Data layer implement, Presentation layer tiêu thụ qua UseCase.
abstract class TableRepository {
  /// Lấy danh sách khu vực (areas).
  Future<List<AreaEntity>> getAreas();

  /// Lấy danh sách bàn với phân trang.
  Future<List<TableEntity>> getTables({int pageIndex = 1, int pageSize = 100});

  /// Lấy chi tiết một bàn theo [tableId].
  Future<TableDetailEntity> getTableDetail(String tableId);

  /// Tạo order mới cho bàn.
  /// Trả về [orderId] nếu API trả về id, ngược lại trả chuỗi rỗng.
  Future<String> createOrder({
    required String tableId,
    required String accountId,
    required int orderType,
  });

  /// Cập nhật trạng thái một bàn.
  Future<String> updateTableStatus({
    required String tableId,
    required int status,
  });

  /// Lấy danh sách order item theo trạng thái (API status code).
  Future<List<ServeItemEntity>> getOrderItemsByStatus({required int status});

  /// Cập nhật trạng thái hàng loạt cho nhiều order item.
  Future<String> updateOrderItemsStatus({
    required List<String> orderItemIds,
    required int newStatus,
    required String accountId,
    required String changeSource,
    String? assigneeId,
  });
}
