import 'package:clain_the_run/core/api/api_endpoints.dart';
import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provider for ApiClient
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

class ApiClient {
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: ApiEndpoints.connectionTimeout,
        receiveTimeout: ApiEndpoints.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.add(_AuthInterceptor());

    // Auto retry on network failures
    _dio.interceptors.add(
      RetryInterceptor(
        dio: _dio,
        retries: 1,
        retryDelays: const [Duration(milliseconds: 500)],
        retryEvaluator: (error, attempt) {
          // Keep retries conservative to avoid repeated request loops
          // when backend is unreachable (common on emulator/device mismatch).
          return error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.sendTimeout ||
              error.type == DioExceptionType.receiveTimeout;
        },
      ),
    );

    // Only add logger in debug mode
    if (kDebugMode) {
      _dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: false,
          responseBody: false,
          responseHeader: false,
          error: true,
          compact: true,
        ),
      );
    }
  }

  Dio get dio => _dio;

  // GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _sendWithFallback(
      path: path,
      options: options,
      request: (resolvedPath) => _dio.get(
        resolvedPath,
        queryParameters: queryParameters,
        options: options,
      ),
    );
  }

  // POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _sendWithFallback(
      path: path,
      options: options,
      request: (resolvedPath) => _dio.post(
        resolvedPath,
        data: data,
        queryParameters: queryParameters,
        options: options,
      ),
    );
  }

  // PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _sendWithFallback(
      path: path,
      options: options,
      request: (resolvedPath) => _dio.put(
        resolvedPath,
        data: data,
        queryParameters: queryParameters,
        options: options,
      ),
    );
  }

  // PATCH request
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _sendWithFallback(
      path: path,
      options: options,
      request: (resolvedPath) => _dio.patch(
        resolvedPath,
        data: data,
        queryParameters: queryParameters,
        options: options,
      ),
    );
  }

  // DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _sendWithFallback(
      path: path,
      options: options,
      request: (resolvedPath) => _dio.delete(
        resolvedPath,
        data: data,
        queryParameters: queryParameters,
        options: options,
      ),
    );
  }

  // Multipart request for file uploads
  Future<Response> uploadFile(
    String path, {
    required FormData formData,
    Options? options,
    ProgressCallback? onSendProgress,
  }) async {
    return _sendWithFallback(
      path: path,
      options: options,
      request: (resolvedPath) => _dio.post(
        resolvedPath,
        data: formData,
        options: options,
        onSendProgress: onSendProgress,
      ),
    );
  }

  Future<Response> _sendWithFallback({
    required String path,
    required Future<Response> Function(String resolvedPath) request,
    Options? options,
  }) async {
    final candidates = _candidateUrlsFor(path, options);
    DioException? lastError;

    for (final candidate in candidates) {
      try {
        return await request(candidate);
      } on DioException catch (error) {
        if (!_shouldTryAnotherBaseUrl(error) || candidate == candidates.last) {
          rethrow;
        }
        lastError = error;
      }
    }

    throw lastError ??
        DioException(
          requestOptions: RequestOptions(path: path),
          message: 'Request failed before any API host candidate could run.',
        );
  }

  List<String> _candidateUrlsFor(String path, Options? options) {
    if (_isAbsoluteUrl(path)) {
      return <String>[path];
    }

    final isUploadRequest = _isUploadRequest(path);
    final baseUrls = isUploadRequest
        ? ApiEndpoints.candidateUploadBaseUrls
        : ApiEndpoints.candidateBaseUrls;

    return baseUrls.map((baseUrl) => '$baseUrl$path').toList();
  }

  bool _isUploadRequest(String path) {
    if (path.startsWith('/uploads/') || path.startsWith('uploads/')) {
      return true;
    }
    return false;
  }

  bool _isAbsoluteUrl(String path) {
    final uri = Uri.tryParse(path);
    return uri != null && uri.hasScheme && uri.host.isNotEmpty;
  }

  bool _shouldTryAnotherBaseUrl(DioException error) {
    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return true;
    }

    final message = error.message?.toLowerCase() ?? '';
    return message.contains('connection refused') ||
        message.contains('failed host lookup');
  }
}

class _AuthInterceptor extends Interceptor {
  final _storage = const FlutterSecureStorage();
  static const _tokenKey = 'auth_token';

  static const List<String> _publicEndpoints = [
    ApiEndpoints.authLogin,
    ApiEndpoints.authRegister,
  ];

  bool _isPublicEndpoint(String path) {
    final normalizedPath = _normalizePath(path);
    return _publicEndpoints.any((e) => normalizedPath.startsWith(e));
  }

  String _normalizePath(String path) {
    final uri = Uri.tryParse(path);
    if (uri != null && uri.hasScheme && uri.path.isNotEmpty) {
      return uri.path;
    }
    return path;
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_isPublicEndpoint(options.path)) {
      String? token = await _storage.read(key: _tokenKey);
      token ??= (await SharedPreferences.getInstance()).getString(_tokenKey);
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      _storage.delete(key: _tokenKey);
      SharedPreferences.getInstance().then((prefs) => prefs.remove(_tokenKey));
    }
    handler.next(err);
  }
}
