import 'package:clain_the_run/core/error/failures.dart';
import 'package:clain_the_run/core/usecases/app_usecase.dart';
import 'package:clain_the_run/features/auth/data/repositories/auth_repository.dart';
import 'package:clain_the_run/features/auth/domain/entities/auth_entity.dart';
import 'package:clain_the_run/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegisterUsecaseParams extends Equatable {
  const RegisterUsecaseParams({
    required this.fullname,
    required this.email,
    required this.username,
    required this.password,
  });

  final String fullname;
  final String email;
  final String username;
  final String password;

  @override
  List<Object?> get props => [fullname, email, username, password];
}

final registerUsecaseProvider = Provider<RegisterUsecase>((ref) {
  return RegisterUsecase(authRepository: ref.read(authRepositoryProvider));
});

class RegisterUsecase
    implements UsecaseWithParams<AuthEntity, RegisterUsecaseParams> {
  RegisterUsecase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  final IAuthRepository _authRepository;

  @override
  Future<Either<Failure, AuthEntity>> call(RegisterUsecaseParams params) {
    return _authRepository.register(
      AuthEntity(
        fullname: params.fullname,
        email: params.email,
        username: params.username,
        password: params.password,
      ),
    );
  }
}
