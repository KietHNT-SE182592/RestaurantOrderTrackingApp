import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';

// ---------- States ----------

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final UserEntity user;
  AuthSuccess(this.user);
}

class AuthFailure extends AuthState {
  final String error;
  AuthFailure(this.error);
}

// ---------- Cubit ----------

/// Presentation layer chỉ phụ thuộc vào Domain (UseCases), không bao giờ
/// import trực tiếp từ Data layer.
class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;

  AuthCubit({
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
  })  : _loginUseCase = loginUseCase,
        _logoutUseCase = logoutUseCase,
        super(AuthInitial());

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

  Future<void> logout() async {
    await _logoutUseCase();
    emit(AuthInitial());
  }
}