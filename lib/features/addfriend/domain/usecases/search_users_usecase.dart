import 'package:clain_the_run/core/error/failures.dart';
import 'package:clain_the_run/core/usecases/app_usecase.dart';
import 'package:clain_the_run/features/addfriend/data/repositories/addfriend_repository.dart';
import 'package:clain_the_run/features/addfriend/domain/entities/friend_user_entity.dart';
import 'package:clain_the_run/features/addfriend/domain/repositories/addfriend_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final searchUsersUsecaseProvider = Provider<SearchUsersUsecase>((ref) {
  return SearchUsersUsecase(repository: ref.read(addFriendRepositoryProvider));
});

class SearchUsersUsecase
    implements UsecaseWithParams<List<FriendUserEntity>, SearchUsersParams> {
  SearchUsersUsecase({required IAddFriendRepository repository})
    : _repository = repository;

  final IAddFriendRepository _repository;

  @override
  Future<Either<Failure, List<FriendUserEntity>>> call(
    SearchUsersParams params,
  ) {
    return _repository.searchUsers(params.search);
  }
}

class SearchUsersParams extends Equatable {
  const SearchUsersParams({required this.search});
  final String search;
  @override
  List<Object?> get props => [search];
}
