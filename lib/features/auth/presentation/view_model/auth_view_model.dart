import 'package:clain_the_run/features/auth/domain/usecases/login_usecase.dart';
import 'package:clain_the_run/features/auth/domain/usecases/register_usecase.dart';
import 'package:clain_the_run/features/auth/presentation/state/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(
  AuthViewModel.new,
);

class AuthViewModel extends Notifier<AuthState> {
  static const _minimumButtonLoaderDuration = Duration(milliseconds: 1500);
  late final LoginUsecase _loginUsecase;
  late final RegisterUsecase _registerUsecase;

  @override
  AuthState build() {
    _loginUsecase = ref.read(loginUsecaseProvider);
    _registerUsecase = ref.read(registerUsecaseProvider);
    return const AuthState.initial();
  }

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    final result = await _runWithMinimumLoader(() {
      return _loginUsecase(
        LoginUsecaseParams(email: email, password: password),
      );
    });

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (user) =>
          state = AuthState(status: AuthStatus.authenticated, authEntity: user),
    );
  }

  Future<void> register({
    required String fullname,
    required String email,
    required String username,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    final result = await _runWithMinimumLoader(() {
      return _registerUsecase(
        RegisterUsecaseParams(
          fullname: fullname,
          email: email,
          username: username,
          password: password,
        ),
      );
    });

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (user) =>
          state = AuthState(status: AuthStatus.registered, authEntity: user),
    );
  }

  void resetState() {
    state = const AuthState.initial();
  }

  Future<T> _runWithMinimumLoader<T>(Future<T> Function() action) async {
    final result = await Future.wait<dynamic>([
      action(),
      Future<void>.delayed(_minimumButtonLoaderDuration),
    ]);
    return result.first as T;
  }
}
