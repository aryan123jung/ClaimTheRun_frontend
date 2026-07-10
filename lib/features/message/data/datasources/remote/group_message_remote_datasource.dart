import 'package:clain_the_run/core/api/api_client.dart';
import 'package:clain_the_run/core/api/api_endpoints.dart';
import 'package:clain_the_run/features/message/data/datasources/group_message_datasource.dart';
import 'package:clain_the_run/features/message/data/models/message_api_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final groupMessageRemoteDatasourceProvider = Provider<IGroupMessageDatasource>((
  ref,
) {
  return GroupMessageRemoteDatasource(apiClient: ref.read(apiClientProvider));
});

class GroupMessageRemoteDatasource implements IGroupMessageDatasource {
  GroupMessageRemoteDatasource({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<List<GroupMessageApiModel>> getGroupMessages(
    String communityId,
  ) async {
    final response = await _apiClient.get(
      ApiEndpoints.groupMessages(communityId),
    );
    final items = (response.data['data'] as List?) ?? const [];
    return items
        .map(
          (item) => GroupMessageApiModel.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }

  @override
  Future<GroupMessageApiModel> sendGroupMessage(
    String communityId,
    String text,
  ) async {
    final response = await _apiClient.post(
      ApiEndpoints.groupMessages(communityId),
      data: {'text': text},
    );
    return GroupMessageApiModel.fromJson(
      Map<String, dynamic>.from(response.data['data'] as Map),
    );
  }
}
