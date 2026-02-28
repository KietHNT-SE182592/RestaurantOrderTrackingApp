import 'package:equatable/equatable.dart';

/// Lớp cha đại diện cho mọi lỗi trong Domain.
/// Implements Exception để có thể dùng try/catch thay vì Either (không cần thêm fpdart).
abstract class Failure extends Equatable implements Exception {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];

  @override
  String toString() => '$runtimeType: $message';
}

/// Lỗi từ phía Server / network.
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// Lỗi từ phía Cache / local storage.
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}
