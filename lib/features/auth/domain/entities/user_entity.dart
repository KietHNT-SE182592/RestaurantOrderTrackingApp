class UserEntity {
  final String id;
  final String userName;
  final String fullName;
  final String role;
  final String accessToken;
  final String refreshToken;

  const UserEntity({
    required this.id,
    required this.userName,
    required this.fullName,
    required this.role,
    required this.accessToken,
    required this.refreshToken,
  });
}