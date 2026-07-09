import 'package:clain_the_run/core/error/failures.dart';
import 'package:clain_the_run/core/usecases/app_usecase.dart';
import 'package:clain_the_run/features/auth/data/repositories/auth_repository.dart';
import 'package:clain_the_run/features/auth/domain/entities/auth_entity.dart';
import 'package:clain_the_run/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginUsecaseParams extends Equatable {
  const LoginUsecaseParams({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

final loginUsecaseProvider = Provider<LoginUsecase>((ref) {
  return LoginUsecase(authRepository: ref.read(authRepositoryProvider));
});

class LoginUsecase
    implements UsecaseWithParams<AuthEntity, LoginUsecaseParams> {
  LoginUsecase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  final IAuthRepository _authRepository;

  @override
  Future<Either<Failure, AuthEntity>> call(LoginUsecaseParams params) {
    return _authRepository.login(params.email, params.password);
  }
}

final getCurrentUserUsecaseProvider = Provider<GetCurrentUserUsecase>((ref) {
  return GetCurrentUserUsecase(
    authRepository: ref.read(authRepositoryProvider),
  );
});

class GetCurrentUserUsecase implements UsecaseWithoutParams<AuthEntity> {
  GetCurrentUserUsecase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  final IAuthRepository _authRepository;

  @override
  Future<Either<Failure, AuthEntity>> call() {
    return _authRepository.getCurrentUser();
  }
}

class UpdateProfileUsecaseParams extends Equatable {
  const UpdateProfileUsecaseParams({this.fullname, this.bio, this.profileUrl});

  final String? fullname;
  final String? bio;
  final String? profileUrl;

  @override
  List<Object?> get props => [fullname, bio, profileUrl];
}

final updateProfileUsecaseProvider = Provider<UpdateProfileUsecase>((ref) {
  return UpdateProfileUsecase(authRepository: ref.read(authRepositoryProvider));
});

class UpdateProfileUsecase
    implements UsecaseWithParams<AuthEntity, UpdateProfileUsecaseParams> {
  UpdateProfileUsecase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  final IAuthRepository _authRepository;

  @override
  Future<Either<Failure, AuthEntity>> call(UpdateProfileUsecaseParams params) {
    return _authRepository.updateProfile(
      fullname: params.fullname,
      bio: params.bio,
      profileUrl: params.profileUrl,
    );
  }
}
