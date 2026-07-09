import 'package:clain_the_run/core/error/failures.dart';
import 'package:clain_the_run/core/usecases/app_usecase.dart';
import 'package:clain_the_run/features/addfriend/data/repositories/addfriend_repository.dart';
import 'package:clain_the_run/features/addfriend/domain/entities/friend_request_entity.dart';
import 'package:clain_the_run/features/addfriend/domain/repositories/addfriend_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getIncomingRequestsUsecaseProvider = Provider<GetIncomingRequestsUsecase>(
  (ref) {
    return GetIncomingRequestsUsecase(
      repository: ref.read(addFriendRepositoryProvider),
    );
  },
);

class GetIncomingRequestsUsecase
    implements UsecaseWithoutParams<List<FriendRequestEntity>> {
  GetIncomingRequestsUsecase({required IAddFriendRepository repository})
    : _repository = repository;

  final IAddFriendRepository _repository;

  @override
  Future<Either<Failure, List<FriendRequestEntity>>> call() {
    return _repository.getIncomingRequests();
  }
}
