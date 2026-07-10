import 'package:clain_the_run/core/error/failures.dart';
import 'package:clain_the_run/features/message/data/datasources/group_message_datasource.dart';
import 'package:clain_the_run/features/message/data/datasources/remote/group_message_remote_datasource.dart';
import 'package:clain_the_run/features/message/domain/entities/message_entities.dart';
import 'package:clain_the_run/features/message/domain/repositories/group_message_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final groupMessageRepositoryProvider = Provider<IGroupMessageRepository>((ref) {
  return GroupMessageRepository(
    datasource: ref.read(groupMessageRemoteDatasourceProvider),
  );
});

class GroupMessageRepository implements IGroupMessageRepository {
  GroupMessageRepository({required IGroupMessageDatasource datasource})
    : _datasource = datasource;

  final IGroupMessageDatasource _datasource;

  @override
  Future<Either<Failure, List<GroupMessageEntity>>> getGroupMessages(
    String communityId,
  ) async {
    try {
      final items = await _datasource.getGroupMessages(communityId);
      return Right(items.map((item) => item.toEntity()).toList());
    } on DioException catch (error) {
      return Left(
        ApiFailure(message: _message(error, 'Could not load group messages')),
      );
    } catch (error) {
      return Left(ApiFailure(message: error.toString()));
    }
  }

  @override
  Future<Either<Failure, GroupMessageEntity>> sendGroupMessage(
    String communityId,
    String text,
  ) async {
    try {
      final item = await _datasource.sendGroupMessage(communityId, text);
      return Right(item.toEntity());
    } on DioException catch (error) {
      return Left(
        ApiFailure(message: _message(error, 'Could not send group message')),
      );
    } catch (error) {
      return Left(ApiFailure(message: error.toString()));
    }
  }

  String _message(DioException error, String fallback) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
    }
    return fallback;
  }
}
