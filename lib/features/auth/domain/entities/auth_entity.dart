import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  const AuthEntity({
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

  AuthEntity copyWith({
    String? id,
    String? fullname,
    String? email,
    String? username,
    String? password,
    String? profileUrl,
    String? token,
  }) {
    return AuthEntity(
      id: id ?? this.id,
      fullname: fullname ?? this.fullname,
      email: email ?? this.email,
      username: username ?? this.username,
      password: password ?? this.password,
      profileUrl: profileUrl ?? this.profileUrl,
      token: token ?? this.token,
    );
  }

  @override
  List<Object?> get props => [
    id,
    fullname,
    email,
    username,
    password,
    profileUrl,
    token,
  ];
}
