import 'package:clain_the_run/core/error/failures.dart';
import 'package:dartz/dartz.dart';

abstract interface class UsecaseWithParams<Result, Params> {
  Future<Either<Failure, Result>> call(Params params);
}

abstract interface class UsecaseWithoutParams<Result> {
  Future<Either<Failure, Result>> call();
}
