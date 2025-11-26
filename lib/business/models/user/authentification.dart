import 'dart:convert';

class Authentication {
  final String email;
  final String password;

  Authentication({
    required this.email,
    required this.password,
  });

  factory Authentication.fromRawJson(String str) => Authentication.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Authentication.fromJson(Map<String, dynamic> json) => Authentication(
    email: json["email"],
    password: json["password"],
  );

  Map<String, dynamic> toJson() => {
    "email": email,
    "password": password,
  };
}