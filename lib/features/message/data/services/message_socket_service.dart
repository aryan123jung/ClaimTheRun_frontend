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
  final Set<String> _pendingConversationJoins = <String>{};
  io.Socket? _socket;
  void Function(MessageEntity message)? _onMessage;
  bool _isConnecting = false;
  int _socketUrlIndex = 0;

  Future<void> connect() async {
    if (_socket != null) {
      if (_socket!.connected) {
        _flushPendingConversationJoins();
      }
      return;
    }
    if (_isConnecting) return;
    _isConnecting = true;

    final token = await _readToken();
    if (token == null || token.isEmpty) {
      _isConnecting = false;
      return;
    }

    final socketBaseUrls = ApiEndpoints.candidateUploadBaseUrls;
    final socketBaseUrl =
        socketBaseUrls[_socketUrlIndex.clamp(0, socketBaseUrls.length - 1)];
    final socket = io.io(
      socketBaseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': token})
          .build(),
    );

    socket.onConnect((_) {
      _isConnecting = false;
      _flushPendingConversationJoins();
    });

    socket.onConnectError((_) {
      _tryNextSocketHost(socketBaseUrls);
      _isConnecting = false;
    });

    socket.onError((_) {
      _tryNextSocketHost(socketBaseUrls);
      _isConnecting = false;
    });

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

  void joinConversation(String conversationId) {
    final trimmed = conversationId.trim();
    if (trimmed.isEmpty) return;

    _pendingConversationJoins.add(trimmed);
    final socket = _socket;
    if (socket?.connected == true) {
      socket!.emit('conversation:join', trimmed);
      return;
    }

    connect();
  }

  void leaveConversation(String conversationId) {
    final trimmed = conversationId.trim();
    _pendingConversationJoins.remove(trimmed);
    _socket?.emit('conversation:leave', trimmed);
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
    _isConnecting = false;
    _socketUrlIndex = 0;
    _pendingConversationJoins.clear();
  }

  void _flushPendingConversationJoins() {
    final socket = _socket;
    if (socket?.connected != true) return;

    for (final conversationId in _pendingConversationJoins) {
      socket!.emit('conversation:join', conversationId);
    }
  }

  void _tryNextSocketHost(List<String> socketBaseUrls) {
    if (_socketUrlIndex >= socketBaseUrls.length - 1) {
      return;
    }

    _socket?.dispose();
    _socket = null;
    _socketUrlIndex += 1;
    connect();
  }
}
