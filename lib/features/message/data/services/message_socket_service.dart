import 'package:clain_the_run/core/api/api_endpoints.dart';
import 'package:clain_the_run/features/message/domain/entities/message_entities.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

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
    required this.location,
    this.avatarUrl,
    this.updatedAt,
  });

  final String userId;
  final String name;
  final String? avatarUrl;
  final LatLng location;
  final DateTime? updatedAt;
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
  bool _isConnecting = false;
  int _socketUrlIndex = 0;

  Future<void> connect() async {
    if (_socket != null) {
      if (_socket!.connected) {
        _flushPendingConversationJoins();
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

    socket.onDisconnect((_) {
      _socket?.dispose();
      _socket = null;
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
    String? avatarUrl,
    required LatLng location,
  }) {
    final trimmed = communityId.trim();
    if (trimmed.isEmpty || userId.trim().isEmpty) return;

    final payload = <String, dynamic>{
      'communityId': trimmed,
      'userId': userId.trim(),
      'name': name.trim(),
      'avatarUrl': avatarUrl,
      'latitude': location.latitude,
      'longitude': location.longitude,
    };
    _pendingGroupRunJoins[trimmed] = payload;
    final socket = _socket;
    if (socket?.connected == true) {
      socket!.emit('group:run:join', payload);
      return;
    }

    connect();
  }

  void updateGroupRunLocation({
    required String communityId,
    required String userId,
    required LatLng location,
  }) {
    _socket?.emit('group:run:update', {
      'communityId': communityId.trim(),
      'userId': userId.trim(),
      'latitude': location.latitude,
      'longitude': location.longitude,
    });
  }

  void leaveGroupRun(String communityId) {
    final trimmed = communityId.trim();
    _pendingGroupRunJoins.remove(trimmed);
    _socket?.emit('group:run:leave', trimmed);
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
    _pendingGroupJoins.clear();
    _pendingGroupVoiceJoins.clear();
    _pendingGroupRunJoins.clear();
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
      avatarUrl: raw['avatarUrl']?.toString(),
      location: LatLng(latitude, longitude),
      updatedAt: DateTime.tryParse(raw['updatedAt']?.toString() ?? ''),
    );
  }
}
