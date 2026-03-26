import '../entities/chef_member_entity.dart';
import '../repositories/chef_repository.dart';

class GetAvailableChefsUseCase {
  final ChefRepository repository;

  const GetAvailableChefsUseCase(this.repository);

  Future<List<ChefMemberEntity>> call() {
    return repository.getAvailableChefs();
  }
}
