import 'package:clain_the_run/core/error/failures.dart';
import 'package:clain_the_run/features/auth/data/datasources/auth_datasource.dart';
import 'package:clain_the_run/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:clain_the_run/features/auth/data/models/auth_api_model.dart';
import 'package:clain_the_run/features/auth/domain/entities/auth_entity.dart';
import 'package:clain_the_run/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return AuthRepository(
    authRemoteDatasource: ref.read(authRemoteDatasourceProvider),
  );
});

class AuthRepository implements IAuthRepository {
  AuthRepository({required IAuthRemoteDatasource authRemoteDatasource})
    : _authRemoteDatasource = authRemoteDatasource;

  final IAuthRemoteDatasource _authRemoteDatasource;

  @override
  Future<Either<Failure, AuthEntity>> login(
    String email,
    String password,
  ) async {
    try {
      final user = await _authRemoteDatasource.login(email, password);
      if (user == null) {
        return const Left(ApiFailure(message: 'Invalid email or password'));
      }
      return Right(user.toEntity());
    } on DioException catch (error) {
      return Left(
        ApiFailure(
          message: _extractErrorMessage(error) ?? 'Login failed',
          statusCode: error.response?.statusCode,
        ),
      );
    } catch (error) {
      return Left(ApiFailure(message: error.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> register(AuthEntity entity) async {
    try {
      final user = await _authRemoteDatasource.register(
        AuthApiModel.fromEntity(entity),
      );
      if (user == null) {
        return const Left(ApiFailure(message: 'Registration failed'));
      }
      return Right(user.toEntity());
    } on DioException catch (error) {
      return Left(
        ApiFailure(
          message: _extractErrorMessage(error) ?? 'Registration failed',
          statusCode: error.response?.statusCode,
        ),
      );
    } catch (error) {
      return Left(ApiFailure(message: error.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> getCurrentUser() async {
    try {
      final user = await _authRemoteDatasource.getCurrentUser();
      if (user == null) {
        return const Left(ApiFailure(message: 'Could not load profile'));
      }
      return Right(user.toEntity());
    } on DioException catch (error) {
      return Left(
        ApiFailure(
          message: _extractErrorMessage(error) ?? 'Could not load profile',
          statusCode: error.response?.statusCode,
        ),
      );
    } catch (error) {
      return Left(ApiFailure(message: error.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> updateProfile({
    String? fullname,
    String? bio,
    String? profileImagePath,
  }) async {
    try {
      final user = await _authRemoteDatasource.updateProfile(
        fullname: fullname,
        bio: bio,
        profileImagePath: profileImagePath,
      );
      if (user == null) {
        return const Left(ApiFailure(message: 'Profile update failed'));
      }
      return Right(user.toEntity());
    } on DioException catch (error) {
      return Left(
        ApiFailure(
          message: _extractErrorMessage(error) ?? 'Profile update failed',
          statusCode: error.response?.statusCode,
        ),
      );
    } catch (error) {
      return Left(ApiFailure(message: error.toString()));
    }
  }

  String? _extractErrorMessage(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
    }
    return null;
  }
}
