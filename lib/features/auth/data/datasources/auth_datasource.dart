import 'package:clain_the_run/features/auth/data/models/auth_api_model.dart';

abstract interface class IAuthRemoteDatasource {
  Future<AuthApiModel?> register(AuthApiModel user);
  Future<AuthApiModel?> login(String email, String password);
  Future<AuthApiModel?> getCurrentUser();
  Future<AuthApiModel?> updateProfile({
    String? fullname,
    String? bio,
    String? profileImagePath,
  });
}
