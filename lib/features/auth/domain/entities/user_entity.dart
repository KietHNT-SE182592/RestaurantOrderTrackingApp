class UserEntity {
  final String id;
  final String userName;
  final String role;
  final String accessToken;
  final String refreshToken;

  UserEntity({
    required this.id,
    required this.userName,
    required this.role,
    required this.accessToken,
    required this.refreshToken,
  });
}