import 'package:clain_the_run/core/api/api_client.dart';
import 'package:clain_the_run/core/api/api_endpoints.dart';
import 'package:clain_the_run/features/auth/data/datasources/auth_datasource.dart';
import 'package:clain_the_run/features/auth/data/models/auth_api_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

final authRemoteDatasourceProvider = Provider<IAuthRemoteDatasource>((ref) {
  return AuthRemoteDatasource(apiClient: ref.read(apiClientProvider));
});

class AuthRemoteDatasource implements IAuthRemoteDatasource {
  AuthRemoteDatasource({required ApiClient apiClient}) : _apiClient = apiClient;

  static const _tokenKey = 'auth_token';
  final ApiClient _apiClient;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  Future<AuthApiModel?> login(String email, String password) async {
    final response = await _apiClient.post(
      ApiEndpoints.authLogin,
      data: {'email': email, 'password': password},
    );

    if (response.data['success'] == true) {
      final token = response.data['token']?.toString();
      if (token != null && token.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, token);
        await _storage.write(key: _tokenKey, value: token);
      }

      final data = Map<String, dynamic>.from(response.data['data'] as Map);
      data['token'] = token;
      return AuthApiModel.fromJson(data);
    }

    return null;
  }

  @override
  Future<AuthApiModel?> register(AuthApiModel user) async {
    final response = await _apiClient.post(
      ApiEndpoints.authRegister,
      data: user.toJson(),
    );

    if (response.data['success'] == true) {
      final data = Map<String, dynamic>.from(response.data['data'] as Map);
      return AuthApiModel.fromJson(data);
    }

    return null;
  }
}
