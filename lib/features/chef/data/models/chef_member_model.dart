import '../../domain/entities/chef_member_entity.dart';

class ChefMemberModel extends ChefMemberEntity {
  const ChefMemberModel({
    required super.accountId,
    required super.fullName,
    required super.specialty,
    required super.skillLevel,
    required super.isAvailable,
  });

  factory ChefMemberModel.fromJson(Map<String, dynamic> json) {
    return ChefMemberModel(
      accountId: json['accountId'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      specialty: json['specialty']?.toString() ?? '',
      skillLevel: json['skillLevel'] as String? ?? '',
      isAvailable: json['isAvailable'] as bool? ?? false,
    );
  }
}
