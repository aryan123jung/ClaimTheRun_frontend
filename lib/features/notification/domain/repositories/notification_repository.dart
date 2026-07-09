import 'package:clain_the_run/core/error/failures.dart';
import 'package:clain_the_run/features/notification/domain/entities/app_notification_entity.dart';
import 'package:dartz/dartz.dart';

abstract interface class INotificationRepository {
  Future<Either<Failure, List<AppNotificationEntity>>> getNotifications();
  Future<Either<Failure, void>> markRead(String id);
  Future<Either<Failure, void>> markAllRead();
}
