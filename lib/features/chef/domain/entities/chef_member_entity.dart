class ChefMemberEntity {
  final String accountId;
  final String fullName;
  final String specialty;
  final String skillLevel;
  final bool isAvailable;

  const ChefMemberEntity({
    required this.accountId,
    required this.fullName,
    required this.specialty,
    required this.skillLevel,
    required this.isAvailable,
  });

  bool get isAsianSpecialty => specialty.trim() == '2';

  bool get isEuropeanSpecialty => specialty.trim() == '3';
}
