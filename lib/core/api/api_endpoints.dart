import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();
  static const int port = 6060;
  static String? _resolvedApiBaseUrl;
  static String? _resolvedUploadBaseUrl;

  // Runtime overrides:
  // 1) Physical devices (Android + iOS):
  //    flutter run --dart-define=API_HOST=192.168.1.70
  // 2) Android emulator:
  //    flutter run --dart-define=API_HOST_ANDROID=10.0.2.2
  // 3) iOS simulator:
  //    flutter run --dart-define=API_HOST_IOS=localhost
  // 4bag) Full URL override (highest priority):
  //    flutter run --dart-define=API_BASE_URL=http://192.168.1.70:6060/api
  //    flutter run --dart-define=API_UPLOAD_BASE_URL=http://192.168.1.70:6060
  static const String apiBaseUrlOverride = String.fromEnvironment(
    'API_BASE_URL',
  );
  static const String apiUploadBaseUrlOverride = String.fromEnvironment(
    'API_UPLOAD_BASE_URL',
  );
  static const String apiHost = String.fromEnvironment('API_HOST');
  static const String apiHostAndroid = String.fromEnvironment(
    'API_HOST_ANDROID',
  );
  static const String apiHostIos = String.fromEnvironment('API_HOST_IOS');

  // static const String computerIpAddress = "192.168.1.65";
  static const String computerIpAddress = "192.168.1.73";

  // static String get baseUrl {
  //   if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
  //     return "http://$computerIpAddress:$port/api";
  //   }

  //   // if (kIsWeb) {
  //   //   return "http://localhost:$port/api";
  //   // }

  //   if (Platform.isAndroid) {
  //     return "http://10.0.2.2:$port/api";
  //   }

  //   if (Platform.isIOS) {
  //     return "http://localhost:$port/api";
  //   }

  //   return "http://localhost:$port/api";
  // }
  static String get baseUrl {
    final resolved = _resolvedApiBaseUrl;
    if (resolved != null) {
      return resolved;
    }
    final override = _normalizeAbsoluteUrl(apiBaseUrlOverride);
    if (override != null) {
      return override;
    }
    return candidateBaseUrls.first;
  }

  static String get uploadBaseUrl {
    final resolved = _resolvedUploadBaseUrl;
    if (resolved != null) {
      return resolved;
    }
    final override = _normalizeAbsoluteUrl(apiUploadBaseUrlOverride);
    if (override != null) {
      return override;
    }
    return candidateUploadBaseUrls.first;
  }

  static List<String> get candidateBaseUrls {
    final override = _normalizeAbsoluteUrl(apiBaseUrlOverride);
    if (override != null) {
      return <String>[override];
    }

    return _uniquePreservingOrder(
      _candidateHosts().map((host) => 'http://$host:$port/api'),
    );
  }

  static List<String> get candidateUploadBaseUrls {
    final override = _normalizeAbsoluteUrl(apiUploadBaseUrlOverride);
    if (override != null) {
      return <String>[override];
    }

    return _uniquePreservingOrder(
      _candidateHosts().map((host) => 'http://$host:$port'),
    );
  }

  static void debugPrintResolvedEndpoints() {
    // Use this in app startup when diagnosing device connectivity issues.
    // ignore: avoid_print
    print('ApiEndpoints.baseUrl=$baseUrl');
    // ignore: avoid_print
    print('ApiEndpoints.uploadBaseUrl=$uploadBaseUrl');
  }

  static void rememberResolvedApiUrl(String rawUrl) {
    final uri = Uri.tryParse(rawUrl);
    if (uri == null || uri.host.isEmpty) {
      return;
    }

    final apiBase = Uri(
      scheme: uri.scheme,
      host: uri.host,
      port: uri.hasPort ? uri.port : null,
      path: '/api',
    ).toString();
    final uploadBase = Uri(
      scheme: uri.scheme,
      host: uri.host,
      port: uri.hasPort ? uri.port : null,
    ).toString();

    _resolvedApiBaseUrl = apiBase;
    _resolvedUploadBaseUrl = uploadBase;
  }

  static Iterable<String> _candidateHosts() sync* {
    // Web always talks to localhost in local setup.
    if (kIsWeb) {
      yield 'localhost';
      return;
    }

    // Global override first.
    final globalHost = apiHost.trim();
    if (globalHost.isNotEmpty) {
      yield globalHost;
      return;
    }

    // Platform-specific overrides next.
    if (Platform.isAndroid) {
      final androidOverride = apiHostAndroid.trim();
      if (androidOverride.isNotEmpty) {
        yield androidOverride;
        return;
      }

      yield '10.0.2.2';
      yield computerIpAddress;
      return;
    }

    if (Platform.isIOS) {
      final iosOverride = apiHostIos.trim();
      if (iosOverride.isNotEmpty) {
        yield iosOverride;
        return;
      }

      yield 'localhost';
      yield computerIpAddress;
      return;
    }

    yield computerIpAddress;
    yield 'localhost';
  }

  static String? _normalizeAbsoluteUrl(String raw) {
    final value = raw.trim().replaceAll('"', '').replaceAll("'", '');
    if (value.isEmpty) return null;

    final repaired = value
        .replaceFirst(RegExp(r'^hwhattp://', caseSensitive: false), 'http://')
        .replaceFirst(RegExp(r'^htttp://', caseSensitive: false), 'http://')
        .replaceFirst(RegExp(r'^ttp://', caseSensitive: false), 'http://');

    final uri = Uri.tryParse(repaired);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      return null;
    }
    if (uri.scheme != 'http' && uri.scheme != 'https') {
      return null;
    }
    return repaired;
  }

  static List<String> _uniquePreservingOrder(Iterable<String> values) {
    final seen = <String>{};
    final unique = <String>[];

    for (final value in values) {
      if (seen.add(value)) {
        unique.add(value);
      }
    }

    return unique;
  }

  static String uploadUrl(String relativePath) {
    if (relativePath.startsWith('http')) return relativePath;
    final normalized = relativePath.replaceAll('\\', '/').trim();
    final cleaned = normalized.startsWith('/')
        ? normalized.substring(1)
        : normalized;
    return "$uploadBaseUrl/$cleaned";
  }

  /// Profile image URL
  static String profileImageUrl(String fileName) {
    if (fileName.startsWith('http') || fileName.startsWith('data:')) {
      return fileName;
    }
    if (fileName.contains('/') || fileName.contains('\\')) {
      return uploadUrl(fileName);
    }

    // if (isPhysicalDevice) {
    //   return "http://$computerIpAddress:$port/uploads/profile/$fileName";
    // }

    return uploadUrl("uploads/profile/$fileName");
  }

  /// Cover image URL
  static String coverImageUrl(String fileName) {
    if (fileName.startsWith('http')) return fileName;
    if (fileName.contains('/') || fileName.contains('\\')) {
      return uploadUrl(fileName);
    }

    // if (isPhysicalDevice) {
    //   return "http://$computerIpAddress:$port/uploads/cover/$fileName";
    // }

    return uploadUrl("uploads/cover/$fileName");
  }

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  static const String authLogin = '/auth/login';
  static const String authRegister = '/auth/register';
  static const String authUsers = '/auth/users';
  static const String whoAmI = '/auth/whoami';
  static const String authMe = '/auth/me';
  static String getCurrentUserById(String userId) => '/auth/user/$userId';
  static String reportUser(String userId) => '/auth/user/$userId/report';

  static const String sendResetPasswordEmail =
      "/auth/send-reset-password-email";

  static String resetPassword(String token) => "/auth/reset-password/$token";
  static const String verifyResetPasswordMobileCode =
      "/auth/verify-reset-password-mobile-code";
  static const String resetPasswordMobileCode =
      "/auth/reset-password-mobile-code";

  // Profile picture upload
  static const String updateProfileImage = '/auth/update-profile';

  // Cover picture upload
  static const String updateCoverImage = '/auth/update-cover';

  // Posts
  static const String posts = '/post';
  static const String myPosts = '/post/me';
  static String likePost(String id) => '/post/$id/like';
  static String postComments(String id) => '/post/$id/comments';
  static String deletePostComment(String postId, String commentId) =>
      '/post/$postId/comments/$commentId';
  static String reportPost(String postId) => '/post/$postId/report';

  // Friend requests
  static const String friendsBase = '/friends';
  static String sendFriendRequest(String toUserId) =>
      '$friendsBase/requests/$toUserId';
  static String cancelFriendRequest(String toUserId) =>
      '$friendsBase/requests/$toUserId';
  static const String incomingFriendRequests = '$friendsBase/requests/incoming';
  static const String outgoingFriendRequests = '$friendsBase/requests/outgoing';
  static String acceptFriendRequest(String requestId) =>
      '$friendsBase/requests/$requestId/accept';
  static String rejectFriendRequest(String requestId) =>
      '$friendsBase/requests/$requestId/reject';
  static String unfriend(String friendUserId) => '$friendsBase/$friendUserId';
  static String friendStatus(String userId) => '$friendsBase/status/$userId';
  static String friendCount(String userId) => '$friendsBase/count/$userId';

  // Notifications
  static const String notifications = '/notifications';
  static String markNotificationRead(String id) => '$notifications/$id/read';
  static const String markAllNotificationsRead = '$notifications/read-all';

  // Messages
  static const String messagesBase = '/messages';
  static const String conversations = '$messagesBase/conversations';
  static String getOrCreateConversation(String otherUserId) =>
      '$messagesBase/conversations/$otherUserId';
  static String messages(String conversationId) =>
      '$messagesBase/$conversationId';
  static String markConversationRead(String conversationId) =>
      '$messagesBase/$conversationId/read';

  // Calls
  static const String calls = '/calls';

  // Groups
  static const String groupsBase = '/group';
  static const String myGroups = '$groupsBase/my';
  static const String searchGroups = '$groupsBase/search';
  static String groupById(String groupId) => '$groupsBase/$groupId';
  static String joinGroup(String groupId) => '$groupsBase/$groupId/join';
  static String leaveGroup(String groupId) => '$groupsBase/$groupId/leave';
  static String groupPosts(String groupId) => '$groupsBase/$groupId/posts';

  // Reports (generic + admin)
  static const String reportsBase = '/reports';
  static String genericReportPost(String postId) => '$reportsBase/post/$postId';
  static String genericReportUser(String userId) => '$reportsBase/user/$userId';
  static String genericReportGroup(String groupId) =>
      '$reportsBase/group/$groupId';
  static const String myReports = '$reportsBase/my';

  static const String adminReportsStats = '/admin/reports/stats';
  static const String adminReports = '/admin/reports';
  static String adminReportById(String reportId) => '/admin/reports/$reportId';
  static String adminAssignReport(String reportId) =>
      '/admin/reports/$reportId/assign';
  static String adminResolveReport(String reportId) =>
      '/admin/reports/$reportId/resolve';

  static String postMediaUrl(String fileName, String mediaType) {
    if (fileName.startsWith('http')) return fileName;
    if (fileName.contains('/') || fileName.contains('\\')) {
      return uploadUrl(fileName);
    }

    final String folder = mediaType == 'video' ? 'videos' : 'images';
    return uploadUrl("uploads/posts/$folder/$fileName");
  }
}
