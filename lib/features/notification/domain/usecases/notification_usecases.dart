import 'package:clain_the_run/core/error/failures.dart';
import 'package:clain_the_run/core/usecases/app_usecase.dart';
import 'package:clain_the_run/features/notification/data/repositories/notification_repository.dart';
import 'package:clain_the_run/features/notification/domain/entities/app_notification_entity.dart';
import 'package:clain_the_run/features/notification/domain/repositories/notification_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getNotificationsUsecaseProvider = Provider<GetNotificationsUsecase>((
  ref,
) {
  return GetNotificationsUsecase(
    repository: ref.read(notificationRepositoryProvider),
  );
});
final markNotificationReadUsecaseProvider =
    Provider<MarkNotificationReadUsecase>((ref) {
      return MarkNotificationReadUsecase(
        repository: ref.read(notificationRepositoryProvider),
      );
    });
final markAllNotificationsReadUsecaseProvider =
    Provider<MarkAllNotificationsReadUsecase>((ref) {
      return MarkAllNotificationsReadUsecase(
        repository: ref.read(notificationRepositoryProvider),
      );
    });

class GetNotificationsUsecase
    implements UsecaseWithoutParams<List<AppNotificationEntity>> {
  GetNotificationsUsecase({required INotificationRepository repository})
    : _repository = repository;
  final INotificationRepository _repository;
  @override
  Future<Either<Failure, List<AppNotificationEntity>>> call() =>
      _repository.getNotifications();
}

class MarkNotificationReadUsecase
    implements UsecaseWithParams<void, NotificationIdParams> {
  MarkNotificationReadUsecase({required INotificationRepository repository})
    : _repository = repository;
  final INotificationRepository _repository;
  @override
  Future<Either<Failure, void>> call(NotificationIdParams params) =>
      _repository.markRead(params.id);
}

class MarkAllNotificationsReadUsecase implements UsecaseWithoutParams<void> {
  MarkAllNotificationsReadUsecase({required INotificationRepository repository})
    : _repository = repository;
  final INotificationRepository _repository;
  @override
  Future<Either<Failure, void>> call() => _repository.markAllRead();
}

class NotificationIdParams extends Equatable {
  const NotificationIdParams({required this.id});
  final String id;
  @override
  List<Object?> get props => [id];
}
