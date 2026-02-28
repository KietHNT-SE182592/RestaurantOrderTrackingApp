import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/check_auth_status_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';

// ---------- States ----------

abstract class AuthState {}

/// Trạng thái khởi đầu — chưa xác định đăng nhập hay chưa.
class AuthInitial extends AuthState {}

/// Đang thực hiện login / kiểm tra token.
class AuthLoading extends AuthState {}

/// Đã đăng nhập thành công, có đầy đủ thông tin user.
class AuthSuccess extends AuthState {
  final UserEntity user;
  AuthSuccess(this.user);
}

/// Đăng nhập thất bại, có message lỗi.
class AuthFailure extends AuthState {
  final String error;
  AuthFailure(this.error);
}

// ---------- Cubit ----------

/// Presentation layer chỉ phụ thuộc vào Domain (UseCases).
/// Singleton — được dùng chung giữa AppRouter và BlocProvider.
class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;
  final CheckAuthStatusUseCase _checkAuthStatusUseCase;

  AuthCubit({
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
    required CheckAuthStatusUseCase checkAuthStatusUseCase,
  })  : _loginUseCase = loginUseCase,
        _logoutUseCase = logoutUseCase,
        _checkAuthStatusUseCase = checkAuthStatusUseCase,
        super(AuthInitial());

  /// Gọi khi cold start: decode JWT đã lưu để khôi phục session.
  /// Nếu token hợp lệ → emit [AuthSuccess].
  /// Nếu không có / hết hạn → emit [AuthInitial].
  Future<void> checkAuthStatus() async {
    final user = await _checkAuthStatusUseCase();
    if (user != null) {
      emit(AuthSuccess(user));
    } else {
      emit(AuthInitial());
    }
  }

  /// Đăng nhập với username + password.
  Future<void> login(String userName, String password) async {
    emit(AuthLoading());
    try {
      final user = await _loginUseCase(userName, password);
      emit(AuthSuccess(user));
    } on ServerFailure catch (e) {
      emit(AuthFailure(e.message));
    } on CacheFailure catch (e) {
      emit(AuthFailure(e.message));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  /// Đăng xuất: xóa session và trả về [AuthInitial].
  Future<void> logout() async {
    await _logoutUseCase();
    emit(AuthInitial());
  }
}