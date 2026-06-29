import 'package:clain_the_run/core/error/failures.dart';
import 'package:clain_the_run/features/auth/domain/entities/auth_entity.dart';
import 'package:dartz/dartz.dart';

abstract interface class IAuthRepository {
  Future<Either<Failure, AuthEntity>> register(AuthEntity entity);
  Future<Either<Failure, AuthEntity>> login(String email, String password);
}
