import 'package:clain_the_run/core/error/failures.dart';
import 'package:clain_the_run/features/addfriend/data/datasources/addfriend_datasource.dart';
import 'package:clain_the_run/features/addfriend/data/datasources/remote/addfriend_remote_datasource.dart';
import 'package:clain_the_run/features/addfriend/domain/entities/friend_request_entity.dart';
import 'package:clain_the_run/features/addfriend/domain/entities/friend_user_entity.dart';
import 'package:clain_the_run/features/addfriend/domain/repositories/addfriend_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final addFriendRepositoryProvider = Provider<IAddFriendRepository>((ref) {
  return AddFriendRepository(
    datasource: ref.read(addFriendRemoteDatasourceProvider),
  );
});

class AddFriendRepository implements IAddFriendRepository {
  AddFriendRepository({required IAddFriendDatasource datasource})
    : _datasource = datasource;

  final IAddFriendDatasource _datasource;

  @override
  Future<Either<Failure, void>> acceptFriendRequest(String requestId) async {
    return _runVoid(
      () => _datasource.acceptFriendRequest(requestId),
      'Could not accept request',
    );
  }

  @override
  Future<Either<Failure, void>> cancelFriendRequest(String userId) async {
    return _runVoid(
      () => _datasource.cancelFriendRequest(userId),
      'Could not cancel request',
    );
  }

  @override
  Future<Either<Failure, List<FriendRequestEntity>>>
  getIncomingRequests() async {
    try {
      final items = await _datasource.getIncomingRequests();
      return Right(items.map((e) => e.toEntity()).toList());
    } on DioException catch (error) {
      return Left(
        ApiFailure(message: _message(error, 'Could not load requests')),
      );
    } catch (error) {
      return Left(ApiFailure(message: error.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> rejectFriendRequest(String requestId) async {
    return _runVoid(
      () => _datasource.rejectFriendRequest(requestId),
      'Could not reject request',
    );
  }

  @override
  Future<Either<Failure, List<FriendUserEntity>>> searchUsers(
    String search,
  ) async {
    try {
      final items = await _datasource.searchUsers(search);
      return Right(items.map((e) => e.toEntity()).toList());
    } on DioException catch (error) {
      return Left(
        ApiFailure(message: _message(error, 'Could not search users')),
      );
    } catch (error) {
      return Left(ApiFailure(message: error.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendFriendRequest(String userId) async {
    return _runVoid(
      () => _datasource.sendFriendRequest(userId),
      'Could not send request',
    );
  }

  @override
  Future<Either<Failure, void>> unfriend(String userId) async {
    return _runVoid(
      () => _datasource.unfriend(userId),
      'Could not remove friend',
    );
  }

  Future<Either<Failure, void>> _runVoid(
    Future<void> Function() action,
    String fallback,
  ) async {
    try {
      await action();
      return const Right(null);
    } on DioException catch (error) {
      return Left(ApiFailure(message: _message(error, fallback)));
    } catch (error) {
      return Left(ApiFailure(message: error.toString()));
    }
  }

  String _message(DioException error, String fallback) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is String && message.isNotEmpty) return message;
    }
    return fallback;
  }
}
