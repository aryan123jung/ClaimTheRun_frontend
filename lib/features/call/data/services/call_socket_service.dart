import 'dart:async';

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
  Future<void>? _connectFuture;

  void Function(Map<String, dynamic> payload)? onIncomingCall;
  void Function(Map<String, dynamic> payload)? onAccepted;
  void Function(Map<String, dynamic> payload)? onDeclined;
  void Function(Map<String, dynamic> payload)? onEnded;
  void Function(Map<String, dynamic> payload)? onSignal;

  void _log(String message) {
    // ignore: avoid_print
    print('[CallSocket] $message');
  }

  Future<void> connect() async {
    if (_socket != null) {
      if (_socket!.connected) {
        _log('already connected');
        return;
      }
      _socket!.dispose();
      _socket = null;
    }
    if (_isConnecting) {
      await _connectFuture;
      return;
    }
    _isConnecting = true;

    final token = await _readToken();
    if (token == null || token.isEmpty) {
      _log('connect skipped because auth token is missing');
      _isConnecting = false;
      _connectFuture = null;
      return;
    }

    final socketBaseUrls = ApiEndpoints.candidateUploadBaseUrls;
    final socketBaseUrl =
        socketBaseUrls[_socketUrlIndex.clamp(0, socketBaseUrls.length - 1)];
    _log(
      'connecting to $socketBaseUrl candidates=${socketBaseUrls.join(', ')}',
    );
    final completer = Completer<void>();
    _connectFuture = completer.future;
    final socket = io.io(
      socketBaseUrl,
      io.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .enableReconnection()
          .setReconnectionAttempts(5)
          .disableAutoConnect()
          .setAuth({'token': token})
          .setExtraHeaders({'Authorization': 'Bearer $token'})
          .build(),
    );

    socket.onConnect((_) {
      _log('connected as socketId=${socket.id}');
      _isConnecting = false;
      _socketUrlIndex = 0;
      if (!completer.isCompleted) {
        completer.complete();
      }
    });
    socket.onConnectError((error) {
      _log('connect error on $socketBaseUrl: $error');
      if (!completer.isCompleted) {
        completer.completeError(error ?? 'Socket connect error');
      }
      _tryNextSocketHost(socketBaseUrls);
      _isConnecting = false;
    });
    socket.onError((error) {
      _log('socket error on $socketBaseUrl: $error');
      if (!completer.isCompleted) {
        completer.completeError(error ?? 'Socket error');
      }
      _tryNextSocketHost(socketBaseUrls);
      _isConnecting = false;
    });
    socket.onDisconnect((reason) {
      _log('disconnected: $reason');
      _isConnecting = false;
    });
    socket.on('call:incoming', (data) {
      _log('received call:incoming payload=$data');
      if (data is Map) onIncomingCall?.call(Map<String, dynamic>.from(data));
    });
    socket.on('call:accepted', (data) {
      _log('received call:accepted payload=$data');
      if (data is Map) onAccepted?.call(Map<String, dynamic>.from(data));
    });
    socket.on('call:declined', (data) {
      _log('received call:declined payload=$data');
      if (data is Map) onDeclined?.call(Map<String, dynamic>.from(data));
    });
    socket.on('call:ended', (data) {
      _log('received call:ended payload=$data');
      if (data is Map) onEnded?.call(Map<String, dynamic>.from(data));
    });
    socket.on('call:signal', (data) {
      _log('received call:signal payload=$data');
      if (data is Map) onSignal?.call(Map<String, dynamic>.from(data));
    });

    socket.connect();
    _socket = socket;
    try {
      await completer.future.timeout(const Duration(seconds: 5));
    } catch (error) {
      _log('connect wait failed: $error');
    } finally {
      if (identical(_connectFuture, completer.future)) {
        _connectFuture = null;
      }
    }
  }

  Future<void> invite(Map<String, dynamic> payload) async {
    await _emitWhenConnected('call:invite', payload);
  }

  Future<void> accept(Map<String, dynamic> payload) async {
    await _emitWhenConnected('call:accept', payload);
  }

  Future<void> decline(Map<String, dynamic> payload) async {
    await _emitWhenConnected('call:decline', payload);
  }

  Future<void> end(Map<String, dynamic> payload) async {
    await _emitWhenConnected('call:end', payload);
  }

  Future<void> signal(Map<String, dynamic> payload) async {
    await _emitWhenConnected('call:signal', payload);
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
    _connectFuture = null;
  }

  void _tryNextSocketHost(List<String> socketBaseUrls) {
    if (_socketUrlIndex >= socketBaseUrls.length - 1) {
      _log('no more socket hosts left to try');
      return;
    }

    _socket?.dispose();
    _socket = null;
    _socketUrlIndex += 1;
    _isConnecting = false;
    _log('retrying with next socket host index=$_socketUrlIndex');
    connect();
  }

  Future<void> _emitWhenConnected(
    String event,
    Map<String, dynamic> payload,
  ) async {
    final isConnected = await _ensureConnected();
    if (!isConnected) {
      _log('failed to emit $event because socket is still disconnected');
      return;
    }

    _log('emit $event payload=$payload');
    _socket?.emit(event, payload);
  }

  Future<bool> _ensureConnected() async {
    if (_socket?.connected == true) {
      return true;
    }

    _log('socket not connected, attempting reconnect');
    try {
      await connect();
    } catch (error) {
      _log('connect threw while reconnecting: $error');
    }

    if (_socket?.connected == true) {
      return true;
    }

    if (_socket != null) {
      _socket!.connect();
    }

    for (var i = 0; i < 10; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      if (_socket?.connected == true) {
        _log('socket reconnected after retry wait');
        return true;
      }
    }

    return false;
  }
}
