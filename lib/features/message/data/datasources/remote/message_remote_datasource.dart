import 'package:clain_the_run/core/api/api_client.dart';
import 'package:clain_the_run/core/api/api_endpoints.dart';
import 'package:clain_the_run/features/message/data/datasources/message_datasource.dart';
import 'package:clain_the_run/features/message/data/models/message_api_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final messageRemoteDatasourceProvider = Provider<IMessageDatasource>((ref) {
  return MessageRemoteDatasource(apiClient: ref.read(apiClientProvider));
});

class MessageRemoteDatasource implements IMessageDatasource {
  MessageRemoteDatasource({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<List<MessageConversationApiModel>> getConversations() async {
    final response = await _apiClient.get(ApiEndpoints.conversations);
    final data = (response.data['data'] as List?) ?? const [];
    return data
        .map(
          (item) => MessageConversationApiModel.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }

  @override
  Future<List<MessageApiModel>> getMessages(String conversationId) async {
    final response = await _apiClient.get(
      ApiEndpoints.messages(conversationId),
    );
    final data = (response.data['data'] as List?) ?? const [];
    return data
        .map(
          (item) =>
              MessageApiModel.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  @override
  Future<MessageConversationApiModel> getOrCreateConversation(
    String otherUserId,
  ) async {
    final response = await _apiClient.post(
      ApiEndpoints.getOrCreateConversation(otherUserId),
    );
    return MessageConversationApiModel.fromJson(
      Map<String, dynamic>.from(response.data['data'] as Map),
    );
  }

  @override
  Future<void> markConversationRead(String conversationId) async {
    await _apiClient.post(ApiEndpoints.markConversationRead(conversationId));
  }

  @override
  Future<MessageApiModel> sendMessage(
    String conversationId,
    String text,
  ) async {
    final response = await _apiClient.post(
      ApiEndpoints.messages(conversationId),
      data: {'text': text},
    );
    return MessageApiModel.fromJson(
      Map<String, dynamic>.from(response.data['data'] as Map),
    );
  }
}
