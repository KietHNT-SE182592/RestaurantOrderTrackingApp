import '../entities/chef_member_entity.dart';

abstract class ChefRepository {
  Future<List<ChefMemberEntity>> getAvailableChefs();
}
