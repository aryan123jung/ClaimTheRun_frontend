import 'package:clain_the_run/core/error/failures.dart';
import 'package:clain_the_run/core/usecases/app_usecase.dart';
import 'package:clain_the_run/features/addfriend/data/repositories/addfriend_repository.dart';
import 'package:clain_the_run/features/addfriend/domain/repositories/addfriend_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final sendFriendRequestUsecaseProvider = Provider<SendFriendRequestUsecase>((
  ref,
) {
  return SendFriendRequestUsecase(
    repository: ref.read(addFriendRepositoryProvider),
  );
});
final cancelFriendRequestUsecaseProvider = Provider<CancelFriendRequestUsecase>(
  (ref) {
    return CancelFriendRequestUsecase(
      repository: ref.read(addFriendRepositoryProvider),
    );
  },
);
final acceptFriendRequestUsecaseProvider = Provider<AcceptFriendRequestUsecase>(
  (ref) {
    return AcceptFriendRequestUsecase(
      repository: ref.read(addFriendRepositoryProvider),
    );
  },
);
final rejectFriendRequestUsecaseProvider = Provider<RejectFriendRequestUsecase>(
  (ref) {
    return RejectFriendRequestUsecase(
      repository: ref.read(addFriendRepositoryProvider),
    );
  },
);
final unfriendUsecaseProvider = Provider<UnfriendUsecase>((ref) {
  return UnfriendUsecase(repository: ref.read(addFriendRepositoryProvider));
});

class SendFriendRequestUsecase
    implements UsecaseWithParams<void, FriendTargetParams> {
  SendFriendRequestUsecase({required IAddFriendRepository repository})
    : _repository = repository;
  final IAddFriendRepository _repository;
  @override
  Future<Either<Failure, void>> call(FriendTargetParams params) =>
      _repository.sendFriendRequest(params.id);
}

class CancelFriendRequestUsecase
    implements UsecaseWithParams<void, FriendTargetParams> {
  CancelFriendRequestUsecase({required IAddFriendRepository repository})
    : _repository = repository;
  final IAddFriendRepository _repository;
  @override
  Future<Either<Failure, void>> call(FriendTargetParams params) =>
      _repository.cancelFriendRequest(params.id);
}

class AcceptFriendRequestUsecase
    implements UsecaseWithParams<void, FriendTargetParams> {
  AcceptFriendRequestUsecase({required IAddFriendRepository repository})
    : _repository = repository;
  final IAddFriendRepository _repository;
  @override
  Future<Either<Failure, void>> call(FriendTargetParams params) =>
      _repository.acceptFriendRequest(params.id);
}

class RejectFriendRequestUsecase
    implements UsecaseWithParams<void, FriendTargetParams> {
  RejectFriendRequestUsecase({required IAddFriendRepository repository})
    : _repository = repository;
  final IAddFriendRepository _repository;
  @override
  Future<Either<Failure, void>> call(FriendTargetParams params) =>
      _repository.rejectFriendRequest(params.id);
}

class UnfriendUsecase implements UsecaseWithParams<void, FriendTargetParams> {
  UnfriendUsecase({required IAddFriendRepository repository})
    : _repository = repository;
  final IAddFriendRepository _repository;
  @override
  Future<Either<Failure, void>> call(FriendTargetParams params) =>
      _repository.unfriend(params.id);
}

class FriendTargetParams extends Equatable {
  const FriendTargetParams({required this.id});
  final String id;
  @override
  List<Object?> get props => [id];
}
