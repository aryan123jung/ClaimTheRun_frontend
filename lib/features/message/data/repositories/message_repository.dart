import 'package:clain_the_run/core/error/failures.dart';
import 'package:clain_the_run/features/message/data/datasources/message_datasource.dart';
import 'package:clain_the_run/features/message/data/datasources/remote/message_remote_datasource.dart';
import 'package:clain_the_run/features/message/domain/entities/message_entities.dart';
import 'package:clain_the_run/features/message/domain/repositories/message_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final messageRepositoryProvider = Provider<IMessageRepository>((ref) {
  return MessageRepository(
    datasource: ref.read(messageRemoteDatasourceProvider),
  );
});

class MessageRepository implements IMessageRepository {
  MessageRepository({required IMessageDatasource datasource})
    : _datasource = datasource;

  final IMessageDatasource _datasource;

  @override
  Future<Either<Failure, List<MessageConversationEntity>>>
  getConversations() async {
    try {
      final items = await _datasource.getConversations();
      return Right(items.map((item) => item.toEntity()).toList());
    } on DioException catch (error) {
      return Left(
        ApiFailure(message: _message(error, 'Could not load conversations')),
      );
    } catch (error) {
      return Left(ApiFailure(message: error.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MessageEntity>>> getMessages(
    String conversationId,
  ) async {
    try {
      final items = await _datasource.getMessages(conversationId);
      return Right(items.map((item) => item.toEntity()).toList());
    } on DioException catch (error) {
      return Left(
        ApiFailure(message: _message(error, 'Could not load messages')),
      );
    } catch (error) {
      return Left(ApiFailure(message: error.toString()));
    }
  }

  @override
  Future<Either<Failure, MessageConversationEntity>> getOrCreateConversation(
    String otherUserId,
  ) async {
    try {
      final item = await _datasource.getOrCreateConversation(otherUserId);
      return Right(item.toEntity());
    } on DioException catch (error) {
      return Left(
        ApiFailure(message: _message(error, 'Could not open conversation')),
      );
    } catch (error) {
      return Left(ApiFailure(message: error.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markConversationRead(
    String conversationId,
  ) async {
    try {
      await _datasource.markConversationRead(conversationId);
      return const Right(null);
    } on DioException catch (error) {
      return Left(
        ApiFailure(
          message: _message(error, 'Could not mark conversation as read'),
        ),
      );
    } catch (error) {
      return Left(ApiFailure(message: error.toString()));
    }
  }

  @override
  Future<Either<Failure, MessageEntity>> sendMessage(
    String conversationId,
    String text,
  ) async {
    try {
      final item = await _datasource.sendMessage(conversationId, text);
      return Right(item.toEntity());
    } on DioException catch (error) {
      return Left(
        ApiFailure(message: _message(error, 'Could not send message')),
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
