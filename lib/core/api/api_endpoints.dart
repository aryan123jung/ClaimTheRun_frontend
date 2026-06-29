import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();
  static const int port = 6060;

  // Runtime overrides:
  // 1) Physical devices (Android + iOS):
  //    flutter run --dart-define=API_HOST=192.168.1.70
  // 2) Android emulator:
  //    flutter run --dart-define=API_HOST_ANDROID=10.0.2.2
  // 3) iOS simulator:
  //    flutter run --dart-define=API_HOST_IOS=localhost
  // 4) Full URL override (highest priority):
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

  static const String computerIpAddress = "192.168.1.65";

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
    final override = _normalizeAbsoluteUrl(apiBaseUrlOverride);
    if (override != null) {
      return override;
    }
    return "http://${_resolveHost()}:$port/api";
  }

  static String get uploadBaseUrl {
    final override = _normalizeAbsoluteUrl(apiUploadBaseUrlOverride);
    if (override != null) {
      return override;
    }
    return "http://${_resolveHost()}:$port";
  }

  static void debugPrintResolvedEndpoints() {
    // Use this in app startup when diagnosing device connectivity issues.
    // ignore: avoid_print
    print('ApiEndpoints.baseUrl=$baseUrl');
    // ignore: avoid_print
    print('ApiEndpoints.uploadBaseUrl=$uploadBaseUrl');
  }

  static String _resolveHost() {
    // Web always talks to localhost in local setup.
    if (kIsWeb) return 'localhost';

    // Global override first.
    if (apiHost.trim().isNotEmpty) return apiHost.trim();

    // Platform-specific overrides.
    if (Platform.isAndroid && apiHostAndroid.trim().isNotEmpty) {
      return apiHostAndroid.trim();
    }
    if (Platform.isIOS && apiHostIos.trim().isNotEmpty) {
      return apiHostIos.trim();
    }

    // Physical-device-first default.
    // This avoids "localhost connection refused" on real phone.
    return computerIpAddress;
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
    if (fileName.startsWith('http')) return fileName;
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

  // Chautari (Community)
  static const String chautari = '/chautari';
  static const String myChautari = '$chautari/my';
  static const String searchChautari = '$chautari/search';
  static String chautariById(String communityId) => '$chautari/$communityId';
  static String joinChautari(String communityId) =>
      '$chautari/$communityId/join';
  static String leaveChautari(String communityId) =>
      '$chautari/$communityId/leave';
  static String chautariMemberCount(String communityId) =>
      '$chautari/$communityId/member-count';
  static String chautariCountByUser(String userId) => '$chautari/count/$userId';
  static String chautariPosts(String communityId) =>
      '$chautari/$communityId/posts';
  static String reportChautari(String communityId) =>
      '$chautari/$communityId/report';

  // Reports (generic + admin)
  static const String reportsBase = '/reports';
  static String genericReportPost(String postId) => '$reportsBase/post/$postId';
  static String genericReportUser(String userId) => '$reportsBase/user/$userId';
  static String genericReportChautari(String communityId) =>
      '$reportsBase/chautari/$communityId';
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
