import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/chef_member_entity.dart';
import '../../domain/repositories/chef_repository.dart';
import '../datasources/chef_remote_datasource.dart';

class ChefRepositoryImpl implements ChefRepository {
  final ChefRemoteDataSource remoteDataSource;

  const ChefRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<ChefMemberEntity>> getAvailableChefs() async {
    try {
      return await remoteDataSource.getAvailableChefs();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }
}
