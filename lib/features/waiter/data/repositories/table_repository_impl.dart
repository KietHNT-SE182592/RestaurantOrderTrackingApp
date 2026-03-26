import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/area_entity.dart';
import '../../domain/entities/serve_item_entity.dart';
import '../../domain/entities/table_detail_entity.dart';
import '../../domain/entities/table_entity.dart';
import '../../domain/repositories/table_repository.dart';
import '../datasources/table_remote_datasource.dart';

class TableRepositoryImpl implements TableRepository {
  final TableRemoteDataSource remoteDataSource;

  const TableRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<AreaEntity>> getAreas() async {
    try {
      return await remoteDataSource.getAreas();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<List<TableEntity>> getTables({
    int pageIndex = 1,
    int pageSize = 100,
  }) async {
    try {
      return await remoteDataSource.getTables(
        pageIndex: pageIndex,
        pageSize: pageSize,
      );
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<TableDetailEntity> getTableDetail(String tableId) async {
    try {
      return await remoteDataSource.getTableDetail(tableId);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<String> createOrder({
    required String tableId,
    required String accountId,
    required int orderType,
  }) async {
    try {
      return await remoteDataSource.createOrder(
        tableId: tableId,
        accountId: accountId,
        orderType: orderType,
      );
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<String> updateTableStatus({
    required String tableId,
    required int status,
  }) async {
    try {
      return await remoteDataSource.updateTableStatus(
        tableId: tableId,
        status: status,
      );
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<List<ServeItemEntity>> getOrderItemsByStatus({
    required int status,
  }) async {
    try {
      return await remoteDataSource.getOrderItemsByStatus(status: status);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<List<ServeItemEntity>> getOrderItemsByAccount() async {
    try {
      return await remoteDataSource.getOrderItemsByAccount();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<String> updateOrderItemsStatus({
    required List<String> orderItemIds,
    required int newStatus,
    String? accountId,
    String? changeSource,
    String? assigneeId,
  }) async {
    try {
      return await remoteDataSource.updateOrderItemsStatus(
        orderItemIds: orderItemIds,
        newStatus: newStatus,
        accountId: accountId,
        changeSource: changeSource,
        assigneeId: assigneeId,
      );
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }
}
