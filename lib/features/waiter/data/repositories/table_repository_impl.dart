import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/area_entity.dart';
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
}
