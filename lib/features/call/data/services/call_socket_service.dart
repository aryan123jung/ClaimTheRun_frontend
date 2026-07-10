import 'package:clain_the_run/core/api/api_endpoints.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

final callSocketServiceProvider = Provider<CallSocketService>((ref) {
  final service = CallSocketService();
  ref.onDispose(service.dispose);
  return service;
});

class CallSocketService {
  static const _tokenKey = 'auth_token';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  io.Socket? _socket;
  bool _isConnecting = false;
  int _socketUrlIndex = 0;

  void Function(Map<String, dynamic> payload)? onIncomingCall;
  void Function(Map<String, dynamic> payload)? onAccepted;
  void Function(Map<String, dynamic> payload)? onDeclined;
  void Function(Map<String, dynamic> payload)? onEnded;
  void Function(Map<String, dynamic> payload)? onSignal;

  Future<void> connect() async {
    if (_socket != null) {
      if (_socket!.connected) {
        return;
      }
      _socket!.dispose();
      _socket = null;
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
    });
    socket.onConnectError((_) {
      _tryNextSocketHost(socketBaseUrls);
      _isConnecting = false;
    });
    socket.onError((_) {
      _tryNextSocketHost(socketBaseUrls);
      _isConnecting = false;
    });
    socket.onDisconnect((_) {
      _socket?.dispose();
      _socket = null;
      _isConnecting = false;
    });
    socket.on('call:incoming', (data) {
      if (data is Map) onIncomingCall?.call(Map<String, dynamic>.from(data));
    });
    socket.on('call:accepted', (data) {
      if (data is Map) onAccepted?.call(Map<String, dynamic>.from(data));
    });
    socket.on('call:declined', (data) {
      if (data is Map) onDeclined?.call(Map<String, dynamic>.from(data));
    });
    socket.on('call:ended', (data) {
      if (data is Map) onEnded?.call(Map<String, dynamic>.from(data));
    });
    socket.on('call:signal', (data) {
      if (data is Map) onSignal?.call(Map<String, dynamic>.from(data));
    });

    socket.connect();
    _socket = socket;
  }

  void invite(Map<String, dynamic> payload) =>
      _socket?.emit('call:invite', payload);
  void accept(Map<String, dynamic> payload) =>
      _socket?.emit('call:accept', payload);
  void decline(Map<String, dynamic> payload) =>
      _socket?.emit('call:decline', payload);
  void end(Map<String, dynamic> payload) => _socket?.emit('call:end', payload);
  void signal(Map<String, dynamic> payload) =>
      _socket?.emit('call:signal', payload);

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
