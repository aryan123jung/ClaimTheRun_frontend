import 'package:clain_the_run/core/error/failures.dart';
import 'package:clain_the_run/features/social/data/repositories/social_repository.dart';
import 'package:clain_the_run/features/social/domain/entities/group_entity.dart';
import 'package:clain_the_run/features/social/domain/repositories/social_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final createGroupUsecaseProvider = Provider<CreateGroupUsecase>((ref) {
  return CreateGroupUsecase(repository: ref.read(socialRepositoryProvider));
});

class CreateGroupUsecase {
  CreateGroupUsecase({required ISocialRepository repository})
    : _repository = repository;

  final ISocialRepository _repository;

  Future<Either<Failure, GroupEntity>> call(CreateGroupParams params) {
    return _repository.createGroup(
      name: params.name,
      description: params.description,
      imagePath: params.imagePath,
    );
  }
}

class CreateGroupParams {
  const CreateGroupParams({
    required this.name,
    required this.description,
    this.imagePath,
  });

  final String name;
  final String description;
  final String? imagePath;
}
