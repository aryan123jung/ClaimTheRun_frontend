import 'package:clain_the_run/core/api/api_endpoints.dart';
import 'package:clain_the_run/features/message/domain/entities/message_entities.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

final messageSocketServiceProvider = Provider<MessageSocketService>((ref) {
  final service = MessageSocketService();
  ref.onDispose(service.dispose);
  return service;
});

class MessageSocketService {
  static const _tokenKey = 'auth_token';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  io.Socket? _socket;
  void Function(MessageEntity message)? _onMessage;

  Future<void> connect() async {
    if (_socket?.connected == true) return;

    final token = await _readToken();
    if (token == null || token.isEmpty) return;

    final socket = io.io(
      ApiEndpoints.uploadBaseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': token})
          .build(),
    );

    socket.on('message:new', (data) {
      if (data is! Map) return;
      final payload = MessageEntity(
        id: data['id']?.toString() ?? '',
        conversationId: data['conversationId']?.toString() ?? '',
        text: data['text']?.toString() ?? '',
        senderId: data['senderId']?.toString() ?? '',
        receiverId: data['receiverId']?.toString() ?? '',
        createdAt:
            DateTime.tryParse(data['createdAt']?.toString() ?? '') ??
            DateTime.now(),
        isMine: data['isMine'] == true,
        isReadByOtherUser: data['isReadByOtherUser'] == true,
      );
      _onMessage?.call(payload);
    });

    socket.connect();
    _socket = socket;
  }

  Future<void> joinConversation(String conversationId) async {
    await connect();
    _socket?.emit('conversation:join', conversationId);
  }

  void leaveConversation(String conversationId) {
    _socket?.emit('conversation:leave', conversationId);
  }

  void setOnMessage(void Function(MessageEntity message)? listener) {
    _onMessage = listener;
  }

  Future<String?> _readToken() async {
    var token = await _storage.read(key: _tokenKey);
    token ??= (await SharedPreferences.getInstance()).getString(_tokenKey);
    return token;
  }

  void dispose() {
    _socket?.dispose();
    _socket = null;
  }
}
