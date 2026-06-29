import 'package:clain_the_run/features/auth/domain/entities/auth_entity.dart';

class AuthApiModel {
  const AuthApiModel({
    this.id,
    required this.fullname,
    required this.email,
    required this.username,
    this.password,
    this.profileUrl,
    this.token,
  });

  final String? id;
  final String fullname;
  final String email;
  final String username;
  final String? password;
  final String? profileUrl;
  final String? token;

  factory AuthApiModel.fromJson(Map<String, dynamic> json) {
    return AuthApiModel(
      id: (json['_id'] ?? json['id'])?.toString(),
      fullname: (json['fullname'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      username: (json['username'] ?? '').toString(),
      password: json['password']?.toString(),
      profileUrl: json['profileUrl']?.toString(),
      token: json['token']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullname': fullname,
      'email': email,
      'username': username,
      'password': password,
      if (profileUrl != null) 'profileUrl': profileUrl,
    };
  }

  AuthEntity toEntity() {
    return AuthEntity(
      id: id,
      fullname: fullname,
      email: email,
      username: username,
      password: password,
      profileUrl: profileUrl,
      token: token,
    );
  }

  factory AuthApiModel.fromEntity(AuthEntity entity) {
    return AuthApiModel(
      id: entity.id,
      fullname: entity.fullname,
      email: entity.email,
      username: entity.username,
      password: entity.password,
      profileUrl: entity.profileUrl,
      token: entity.token,
    );
  }
}
