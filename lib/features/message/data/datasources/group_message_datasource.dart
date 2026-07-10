import 'package:clain_the_run/features/message/data/models/message_api_models.dart';

abstract interface class IGroupMessageDatasource {
  Future<List<GroupMessageApiModel>> getGroupMessages(String communityId);
  Future<GroupMessageApiModel> sendGroupMessage(
    String communityId,
    String text,
  );
}
