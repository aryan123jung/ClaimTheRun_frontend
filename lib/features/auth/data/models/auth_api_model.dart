import 'package:clain_the_run/features/auth/domain/entities/auth_entity.dart';

class AuthApiModel {
  const AuthApiModel({
    this.id,
    required this.fullname,
    required this.email,
    required this.username,
    this.password,
    this.bio,
    this.profileUrl,
    this.token,
  });

  final String? id;
  final String fullname;
  final String email;
  final String username;
  final String? password;
  final String? bio;
  final String? profileUrl;
  final String? token;

  factory AuthApiModel.fromJson(Map<String, dynamic> json) {
    return AuthApiModel(
      id: (json['_id'] ?? json['id'])?.toString(),
      fullname: (json['fullname'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      username: (json['username'] ?? '').toString(),
      password: json['password']?.toString(),
      bio: json['bio']?.toString(),
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
      if (bio != null) 'bio': bio,
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
      bio: bio,
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
      bio: entity.bio,
      profileUrl: entity.profileUrl,
      token: entity.token,
    );
  }
}
