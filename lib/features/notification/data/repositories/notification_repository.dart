import 'package:clain_the_run/core/error/failures.dart';
import 'package:clain_the_run/features/notification/data/datasources/notification_datasource.dart';
import 'package:clain_the_run/features/notification/data/datasources/remote/notification_remote_datasource.dart';
import 'package:clain_the_run/features/notification/domain/entities/app_notification_entity.dart';
import 'package:clain_the_run/features/notification/domain/repositories/notification_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationRepositoryProvider = Provider<INotificationRepository>((ref) {
  return NotificationRepository(
    datasource: ref.read(notificationRemoteDatasourceProvider),
  );
});

class NotificationRepository implements INotificationRepository {
  NotificationRepository({required INotificationDatasource datasource})
    : _datasource = datasource;

  final INotificationDatasource _datasource;

  @override
  Future<Either<Failure, List<AppNotificationEntity>>>
  getNotifications() async {
    try {
      final items = await _datasource.getNotifications();
      return Right(items.map((e) => e.toEntity()).toList());
    } on DioException catch (error) {
      return Left(
        ApiFailure(message: _message(error, 'Could not load notifications')),
      );
    } catch (error) {
      return Left(ApiFailure(message: error.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAllRead() async => _runVoid(
    () => _datasource.markAllRead(),
    'Could not mark all notifications as read',
  );

  @override
  Future<Either<Failure, void>> markRead(String id) async => _runVoid(
    () => _datasource.markRead(id),
    'Could not mark notification as read',
  );

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
