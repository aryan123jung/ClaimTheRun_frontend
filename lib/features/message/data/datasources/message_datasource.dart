import 'package:clain_the_run/features/message/data/models/message_api_models.dart';

abstract interface class IMessageDatasource {
  Future<List<MessageConversationApiModel>> getConversations();
  Future<MessageConversationApiModel> getOrCreateConversation(
    String otherUserId,
  );
  Future<List<MessageApiModel>> getMessages(String conversationId);
  Future<MessageApiModel> sendMessage(String conversationId, String text);
  Future<void> markConversationRead(String conversationId);
}
