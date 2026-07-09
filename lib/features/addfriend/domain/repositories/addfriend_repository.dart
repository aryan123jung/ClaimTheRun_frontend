import 'package:clain_the_run/core/error/failures.dart';
import 'package:clain_the_run/features/addfriend/domain/entities/friend_request_entity.dart';
import 'package:clain_the_run/features/addfriend/domain/entities/friend_user_entity.dart';
import 'package:dartz/dartz.dart';

abstract interface class IAddFriendRepository {
  Future<Either<Failure, List<FriendUserEntity>>> searchUsers(String search);
  Future<Either<Failure, List<FriendRequestEntity>>> getIncomingRequests();
  Future<Either<Failure, void>> sendFriendRequest(String userId);
  Future<Either<Failure, void>> cancelFriendRequest(String userId);
  Future<Either<Failure, void>> unfriend(String userId);
  Future<Either<Failure, void>> acceptFriendRequest(String requestId);
  Future<Either<Failure, void>> rejectFriendRequest(String requestId);
}
