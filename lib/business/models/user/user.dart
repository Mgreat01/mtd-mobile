class User {
  final int? id;
  final String? name;
  final String? email;
  final String? token;
  final String? role;
  final String? email_verified_at;

  User({this.id, this.name, this.email, this.token,this.role, this.email_verified_at});

  factory User.fromJson(json) => User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      email_verified_at: json['email_verified_at'],
      token : json['token'],
      role: json['role']
  );

  Map toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'email_verified_at': email_verified_at,
    'token' : token,
    'role': role
  };
}
