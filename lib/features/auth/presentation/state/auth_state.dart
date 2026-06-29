import 'package:clain_the_run/features/auth/domain/entities/auth_entity.dart';
import 'package:equatable/equatable.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  registered,
  unauthenticated,
  error,
}

class AuthState extends Equatable {
  const AuthState({required this.status, this.authEntity, this.errorMessage});

  const AuthState.initial()
    : status = AuthStatus.initial,
      authEntity = null,
      errorMessage = null;

  final AuthStatus status;
  final AuthEntity? authEntity;
  final String? errorMessage;

  AuthState copyWith({
    AuthStatus? status,
    AuthEntity? authEntity,
    bool clearAuthEntity = false,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      authEntity: clearAuthEntity ? null : authEntity ?? this.authEntity,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, authEntity, errorMessage];
}
