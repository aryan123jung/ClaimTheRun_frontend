import 'package:clain_the_run/core/api/api_endpoints.dart';
import 'package:clain_the_run/features/message/domain/entities/message_entities.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'dart:async';

final messageSocketServiceProvider = Provider<MessageSocketService>((ref) {
  final service = MessageSocketService();
  ref.onDispose(service.dispose);
  return service;
});

class GroupVoiceParticipantSocketPayload {
  const GroupVoiceParticipantSocketPayload({
    required this.userId,
    required this.name,
    this.avatarUrl,
  });

  final String userId;
  final String name;
  final String? avatarUrl;
}

class GroupRunParticipantSocketPayload {
  const GroupRunParticipantSocketPayload({
    required this.userId,
    required this.name,
    required this.username,
    required this.location,
    this.avatarUrl,
    this.updatedAt,
  });

  final String userId;
  final String name;
  final String username;
  final String? avatarUrl;
  final LatLng location;
  final DateTime? updatedAt;
}

class GroupRunSessionSocketPayload {
  const GroupRunSessionSocketPayload({
    required this.communityId,
    required this.startedByUserId,
    required this.startedAt,
  });

  final String communityId;
  final String startedByUserId;
  final DateTime startedAt;
}

class MessageSocketService {
  static const _tokenKey = 'auth_token';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final Set<String> _pendingConversationJoins = <String>{};
  final Set<String> _pendingGroupJoins = <String>{};
  final Map<String, Map<String, dynamic>> _pendingGroupVoiceJoins =
      <String, Map<String, dynamic>>{};
  final Map<String, Map<String, dynamic>> _pendingGroupRunJoins =
      <String, Map<String, dynamic>>{};
  final List<_PendingSocketEmit> _pendingCallEmits = <_PendingSocketEmit>[];
  io.Socket? _socket;
  void Function(MessageEntity message)? _onMessage;
  void Function(GroupMessageEntity message)? _onGroupMessage;
  void Function(
    String communityId,
    List<GroupVoiceParticipantSocketPayload> participants,
  )?
  _onGroupVoiceParticipants;
  void Function(
    String communityId,
    GroupVoiceParticipantSocketPayload participant,
  )?
  _onGroupVoiceUserJoined;
  void Function(String communityId, String userId)? _onGroupVoiceUserLeft;
  void Function(Map<String, dynamic> payload)? _onGroupVoiceSignal;
  void Function(String communityId, List<GroupRunParticipantSocketPayload>)?
  _onGroupRunParticipants;
  void Function(String communityId, GroupRunParticipantSocketPayload)?
  _onGroupRunUserJoined;
  void Function(String communityId, GroupRunParticipantSocketPayload)?
  _onGroupRunUserUpdated;
  void Function(String communityId, String userId)? _onGroupRunUserLeft;
  void Function(GroupRunSessionSocketPayload session)? _onGroupRunStarted;
  void Function(String communityId, String stoppedByUserId)? _onGroupRunStopped;
  void Function(Map<String, dynamic> payload)? _onCallIncoming;
  void Function(Map<String, dynamic> payload)? _onCallAccepted;
  void Function(Map<String, dynamic> payload)? _onCallDeclined;
  void Function(Map<String, dynamic> payload)? _onCallEnded;
  void Function(Map<String, dynamic> payload)? _onCallSignal;
  bool _isConnecting = false;
  int _socketUrlIndex = 0;
  Completer<void>? _connectCompleter;

  void _log(String message) {
    // ignore: avoid_print
    print('[MessageSocket] $message');
  }

  Future<void> connect() async {
    if (_socket != null) {
      if (_socket!.connected) {
        _flushPendingConversationJoins();
        _flushPendingCallEmits();
        return;
      }
      if (_isConnecting && _connectCompleter != null) {
        return _connectCompleter!.future.timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            _log('connect wait timed out');
          },
        );
      }
      _socket!.dispose();
      _socket = null;
    }
    if (_isConnecting && _connectCompleter != null) {
      return _connectCompleter!.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          _log('connect wait timed out');
        },
      );
    }
    _isConnecting = true;
    _connectCompleter = Completer<void>();

    final token = await _readToken();
    if (token == null || token.isEmpty) {
      _isConnecting = false;
      _connectCompleter?.complete();
      _connectCompleter = null;
      return;
    }

    final socketBaseUrls = ApiEndpoints.candidateUploadBaseUrls;
    final socketBaseUrl =
        socketBaseUrls[_socketUrlIndex.clamp(0, socketBaseUrls.length - 1)];
    final socket = io.io(
      socketBaseUrl,
      io.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .disableAutoConnect()
          .setAuth({'token': token})
          .setExtraHeaders({'Authorization': 'Bearer $token'})
          .enableReconnection()
          .build(),
    );
    _socket = socket;
    _log('connecting to $socketBaseUrl candidates=$socketBaseUrls');

    socket.onConnect((_) {
      _isConnecting = false;
      _log('connected as socketId=${socket.id}');
      _flushPendingConversationJoins();
      _flushPendingCallEmits();
      if (!(_connectCompleter?.isCompleted ?? true)) {
        _connectCompleter?.complete();
      }
      _connectCompleter = null;
    });

    socket.onConnectError((error) {
      _log('connect error on $socketBaseUrl: $error');
      _tryNextSocketHost(socketBaseUrls);
      _isConnecting = false;
      if (!(_connectCompleter?.isCompleted ?? true)) {
        _connectCompleter?.completeError(error ?? 'Socket connection failed');
      }
      _connectCompleter = null;
    });

    socket.onError((error) {
      _log('socket error on $socketBaseUrl: $error');
      _tryNextSocketHost(socketBaseUrls);
      _isConnecting = false;
      if (!(_connectCompleter?.isCompleted ?? true)) {
        _connectCompleter?.completeError(error ?? 'Socket error');
      }
      _connectCompleter = null;
    });

    socket.onDisconnect((reason) {
      _log('disconnected: $reason');
      _socket?.dispose();
      _socket = null;
      _isConnecting = false;
      if (!(_connectCompleter?.isCompleted ?? true)) {
        _connectCompleter?.completeError('Socket disconnected: $reason');
      }
      _connectCompleter = null;
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

    socket.on('group:message:new', (data) {
      if (data is! Map) return;
      final payload = GroupMessageEntity(
        id: data['id']?.toString() ?? '',
        communityId: data['communityId']?.toString() ?? '',
        text: data['text']?.toString() ?? '',
        createdAt:
            DateTime.tryParse(data['createdAt']?.toString() ?? '') ??
            DateTime.now(),
        sender: GroupSenderEntity(
          id: data['sender']?['id']?.toString() ?? '',
          fullname: data['sender']?['fullname']?.toString() ?? 'Runner',
          username: data['sender']?['username']?.toString() ?? '',
          profileUrl: data['sender']?['profileUrl']?.toString(),
        ),
        isMine: data['isMine'] == true,
      );
      _onGroupMessage?.call(payload);
    });

    socket.on('group:voice:participants', (data) {
      if (data is! Map) return;
      final communityId = data['communityId']?.toString() ?? '';
      final rawItems = data['participants'] as List? ?? const [];
      final participants = rawItems
          .map((item) => _mapGroupVoiceParticipant(item))
          .whereType<GroupVoiceParticipantSocketPayload>()
          .toList();
      _onGroupVoiceParticipants?.call(communityId, participants);
    });

    socket.on('group:voice:user-joined', (data) {
      if (data is! Map) return;
      final communityId = data['communityId']?.toString() ?? '';
      final participant = _mapGroupVoiceParticipant(data['participant']);
      if (participant == null) return;
      _onGroupVoiceUserJoined?.call(communityId, participant);
    });

    socket.on('group:voice:user-left', (data) {
      if (data is! Map) return;
      _onGroupVoiceUserLeft?.call(
        data['communityId']?.toString() ?? '',
        data['userId']?.toString() ?? '',
      );
    });

    socket.on('group:voice:signal', (data) {
      if (data is! Map) return;
      _onGroupVoiceSignal?.call(Map<String, dynamic>.from(data));
    });

    socket.on('group:run:participants', (data) {
      if (data is! Map) return;
      final communityId = data['communityId']?.toString() ?? '';
      final rawItems = data['participants'] as List? ?? const [];
      final participants = rawItems
          .map((item) => _mapGroupRunParticipant(item))
          .whereType<GroupRunParticipantSocketPayload>()
          .toList();
      _onGroupRunParticipants?.call(communityId, participants);
      final session = _mapGroupRunSession(data['session']);
      if (session != null) {
        _onGroupRunStarted?.call(session);
      }
    });

    socket.on('group:run:user-joined', (data) {
      if (data is! Map) return;
      final communityId = data['communityId']?.toString() ?? '';
      final participant = _mapGroupRunParticipant(data['participant']);
      if (participant == null) return;
      _onGroupRunUserJoined?.call(communityId, participant);
    });

    socket.on('group:run:user-updated', (data) {
      if (data is! Map) return;
      final communityId = data['communityId']?.toString() ?? '';
      final participant = _mapGroupRunParticipant(data['participant']);
      if (participant == null) return;
      _onGroupRunUserUpdated?.call(communityId, participant);
    });

    socket.on('group:run:user-left', (data) {
      if (data is! Map) return;
      _onGroupRunUserLeft?.call(
        data['communityId']?.toString() ?? '',
        data['userId']?.toString() ?? '',
      );
    });

    socket.on('group:run:started', (data) {
      final session = _mapGroupRunSession(data);
      if (session == null) return;
      _onGroupRunStarted?.call(session);
    });

    socket.on('group:run:stopped', (data) {
      if (data is! Map) return;
      _onGroupRunStopped?.call(
        data['communityId']?.toString() ?? '',
        data['stoppedByUserId']?.toString() ?? '',
      );
    });

    socket.on('call:incoming', (data) {
      if (data is! Map) return;
      _log('received call:incoming payload=$data');
      _onCallIncoming?.call(Map<String, dynamic>.from(data));
    });

    socket.on('call:accepted', (data) {
      if (data is! Map) return;
      _log('received call:accepted payload=$data');
      _onCallAccepted?.call(Map<String, dynamic>.from(data));
    });

    socket.on('call:declined', (data) {
      if (data is! Map) return;
      _onCallDeclined?.call(Map<String, dynamic>.from(data));
    });

    socket.on('call:ended', (data) {
      if (data is! Map) return;
      _log('received call:ended payload=$data');
      _onCallEnded?.call(Map<String, dynamic>.from(data));
    });

    socket.on('call:signal', (data) {
      if (data is! Map) return;
      _log('received call:signal payload=$data');
      _onCallSignal?.call(Map<String, dynamic>.from(data));
    });

    socket.connect();
    await _connectCompleter!.future.timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        _log('connect wait timed out');
      },
    );
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

  void setOnGroupMessage(void Function(GroupMessageEntity message)? listener) {
    _onGroupMessage = listener;
  }

  void setOnGroupVoiceParticipants(
    void Function(
      String communityId,
      List<GroupVoiceParticipantSocketPayload> participants,
    )?
    listener,
  ) {
    _onGroupVoiceParticipants = listener;
  }

  void setOnGroupVoiceUserJoined(
    void Function(
      String communityId,
      GroupVoiceParticipantSocketPayload participant,
    )?
    listener,
  ) {
    _onGroupVoiceUserJoined = listener;
  }

  void setOnGroupVoiceUserLeft(
    void Function(String communityId, String userId)? listener,
  ) {
    _onGroupVoiceUserLeft = listener;
  }

  void setOnGroupVoiceSignal(
    void Function(Map<String, dynamic> payload)? listener,
  ) {
    _onGroupVoiceSignal = listener;
  }

  void setOnGroupRunParticipants(
    void Function(String communityId, List<GroupRunParticipantSocketPayload>)?
    listener,
  ) {
    _onGroupRunParticipants = listener;
  }

  void setOnGroupRunUserJoined(
    void Function(String communityId, GroupRunParticipantSocketPayload)?
    listener,
  ) {
    _onGroupRunUserJoined = listener;
  }

  void setOnGroupRunUserUpdated(
    void Function(String communityId, GroupRunParticipantSocketPayload)?
    listener,
  ) {
    _onGroupRunUserUpdated = listener;
  }

  void setOnGroupRunUserLeft(
    void Function(String communityId, String userId)? listener,
  ) {
    _onGroupRunUserLeft = listener;
  }

  void setOnGroupRunStarted(
    void Function(GroupRunSessionSocketPayload session)? listener,
  ) {
    _onGroupRunStarted = listener;
  }

  void setOnGroupRunStopped(
    void Function(String communityId, String stoppedByUserId)? listener,
  ) {
    _onGroupRunStopped = listener;
  }

  void setOnCallIncoming(
    void Function(Map<String, dynamic> payload)? listener,
  ) {
    _onCallIncoming = listener;
  }

  void setOnCallAccepted(
    void Function(Map<String, dynamic> payload)? listener,
  ) {
    _onCallAccepted = listener;
  }

  void setOnCallDeclined(
    void Function(Map<String, dynamic> payload)? listener,
  ) {
    _onCallDeclined = listener;
  }

  void setOnCallEnded(void Function(Map<String, dynamic> payload)? listener) {
    _onCallEnded = listener;
  }

  void setOnCallSignal(void Function(Map<String, dynamic> payload)? listener) {
    _onCallSignal = listener;
  }

  void joinGroup(String communityId) {
    final trimmed = communityId.trim();
    if (trimmed.isEmpty) return;

    _pendingGroupJoins.add(trimmed);
    final socket = _socket;
    if (socket?.connected == true) {
      socket!.emit('group:join', trimmed);
      return;
    }

    connect();
  }

  void leaveGroup(String communityId) {
    final trimmed = communityId.trim();
    _pendingGroupJoins.remove(trimmed);
    _socket?.emit('group:leave', trimmed);
  }

  void joinGroupVoice({
    required String communityId,
    required String userId,
    required String name,
    String? avatarUrl,
  }) {
    final trimmed = communityId.trim();
    if (trimmed.isEmpty || userId.trim().isEmpty) return;

    final payload = <String, dynamic>{
      'communityId': trimmed,
      'userId': userId.trim(),
      'name': name.trim(),
      'avatarUrl': avatarUrl,
    };
    _pendingGroupVoiceJoins[trimmed] = payload;
    final socket = _socket;
    if (socket?.connected == true) {
      socket!.emit('group:voice:join', payload);
      return;
    }

    connect();
  }

  void leaveGroupVoice(String communityId) {
    final trimmed = communityId.trim();
    _pendingGroupVoiceJoins.remove(trimmed);
    _socket?.emit('group:voice:leave', trimmed);
  }

  void signalGroupVoice(Map<String, dynamic> payload) {
    _socket?.emit('group:voice:signal', payload);
  }

  void joinGroupRun({
    required String communityId,
    required String userId,
    required String name,
    required String username,
    String? avatarUrl,
    required LatLng location,
  }) {
    final trimmed = communityId.trim();
    if (trimmed.isEmpty || userId.trim().isEmpty) return;

    final payload = <String, dynamic>{
      'communityId': trimmed,
      'userId': userId.trim(),
      'name': name.trim(),
      'username': username.trim(),
      'avatarUrl': avatarUrl,
      'latitude': location.latitude,
      'longitude': location.longitude,
    };
    _pendingGroupRunJoins[trimmed] = payload;
    final socket = _socket;
    if (socket != null) {
      socket.emit('group:run:join', payload);
      return;
    }

    connect();
  }

  void updateGroupRunLocation({
    required String communityId,
    required String userId,
    required LatLng location,
  }) {
    final payload = {
      'communityId': communityId.trim(),
      'userId': userId.trim(),
      'latitude': location.latitude,
      'longitude': location.longitude,
    };
    final socket = _socket;
    if (socket != null) {
      socket.emit('group:run:update', payload);
      return;
    }
    connect();
  }

  void leaveGroupRun(String communityId) {
    final trimmed = communityId.trim();
    _pendingGroupRunJoins.remove(trimmed);
    _socket?.emit('group:run:leave', trimmed);
  }

  void startGroupRun(String communityId) {
    final trimmed = communityId.trim();
    if (trimmed.isEmpty) return;
    final socket = _socket;
    if (socket != null) {
      socket.emit('group:run:start', trimmed);
      return;
    }
    connect();
  }

  void stopGroupRun(String communityId) {
    final trimmed = communityId.trim();
    if (trimmed.isEmpty) return;
    final socket = _socket;
    if (socket != null) {
      socket.emit('group:run:stop', trimmed);
      return;
    }
    connect();
  }

  void inviteCall(Map<String, dynamic> payload) {
    final socket = _socket;
    if (socket?.connected == true) {
      _log('emit call:invite payload=$payload');
      socket!.emit('call:invite', payload);
      return;
    }
    _pendingCallEmits.add(_PendingSocketEmit('call:invite', payload));
    _log('queued call:invite payload=$payload');
    connect();
  }

  void acceptCall(Map<String, dynamic> payload) {
    final socket = _socket;
    if (socket?.connected == true) {
      _log('emit call:accept payload=$payload');
      socket!.emit('call:accept', payload);
      return;
    }
    _pendingCallEmits.add(_PendingSocketEmit('call:accept', payload));
    _log('queued call:accept payload=$payload');
    connect();
  }

  void declineCall(Map<String, dynamic> payload) {
    final socket = _socket;
    if (socket?.connected == true) {
      _log('emit call:decline payload=$payload');
      socket!.emit('call:decline', payload);
      return;
    }
    _pendingCallEmits.add(_PendingSocketEmit('call:decline', payload));
    _log('queued call:decline payload=$payload');
    connect();
  }

  void endCall(Map<String, dynamic> payload) {
    final socket = _socket;
    if (socket?.connected == true) {
      _log('emit call:end payload=$payload');
      socket!.emit('call:end', payload);
      return;
    }
    _pendingCallEmits.add(_PendingSocketEmit('call:end', payload));
    _log('queued call:end payload=$payload');
    connect();
  }

  void signalCall(Map<String, dynamic> payload) {
    final socket = _socket;
    if (socket?.connected == true) {
      _log('emit call:signal payload=$payload');
      socket!.emit('call:signal', payload);
      return;
    }
    _pendingCallEmits.add(_PendingSocketEmit('call:signal', payload));
    _log('queued call:signal payload=$payload');
    connect();
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
    if (!(_connectCompleter?.isCompleted ?? true)) {
      _connectCompleter?.complete();
    }
    _connectCompleter = null;
    _pendingConversationJoins.clear();
    _pendingGroupJoins.clear();
    _pendingGroupVoiceJoins.clear();
    _pendingGroupRunJoins.clear();
    _pendingCallEmits.clear();
  }

  void _flushPendingConversationJoins() {
    final socket = _socket;
    if (socket?.connected != true) return;

    for (final conversationId in _pendingConversationJoins) {
      socket!.emit('conversation:join', conversationId);
    }
    for (final communityId in _pendingGroupJoins) {
      socket!.emit('group:join', communityId);
    }
    for (final payload in _pendingGroupVoiceJoins.values) {
      socket!.emit('group:voice:join', payload);
    }
    for (final payload in _pendingGroupRunJoins.values) {
      socket!.emit('group:run:join', payload);
    }
  }

  void _flushPendingCallEmits() {
    final socket = _socket;
    if (socket?.connected != true || _pendingCallEmits.isEmpty) return;

    final pending = List<_PendingSocketEmit>.from(_pendingCallEmits);
    _pendingCallEmits.clear();
    for (final item in pending) {
      _log('flush ${item.event} payload=${item.payload}');
      socket!.emit(item.event, item.payload);
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

  GroupVoiceParticipantSocketPayload? _mapGroupVoiceParticipant(dynamic raw) {
    if (raw is! Map) return null;
    return GroupVoiceParticipantSocketPayload(
      userId: raw['userId']?.toString() ?? '',
      name: raw['name']?.toString() ?? 'Runner',
      avatarUrl: raw['avatarUrl']?.toString(),
    );
  }

  GroupRunParticipantSocketPayload? _mapGroupRunParticipant(dynamic raw) {
    if (raw is! Map) return null;
    final latitude = (raw['latitude'] as num?)?.toDouble();
    final longitude = (raw['longitude'] as num?)?.toDouble();
    if (latitude == null || longitude == null) return null;
    return GroupRunParticipantSocketPayload(
      userId: raw['userId']?.toString() ?? '',
      name: raw['name']?.toString() ?? 'Runner',
      username: raw['username']?.toString() ?? 'runner',
      avatarUrl: raw['avatarUrl']?.toString(),
      location: LatLng(latitude, longitude),
      updatedAt: DateTime.tryParse(raw['updatedAt']?.toString() ?? ''),
    );
  }

  GroupRunSessionSocketPayload? _mapGroupRunSession(dynamic raw) {
    if (raw is! Map) return null;
    final startedAt = DateTime.tryParse(raw['startedAt']?.toString() ?? '');
    if (startedAt == null) return null;
    return GroupRunSessionSocketPayload(
      communityId: raw['communityId']?.toString() ?? '',
      startedByUserId: raw['startedByUserId']?.toString() ?? '',
      startedAt: startedAt,
    );
  }
}

class _PendingSocketEmit {
  const _PendingSocketEmit(this.event, this.payload);

  final String event;
  final Map<String, dynamic> payload;
}
