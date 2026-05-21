class User {
  final int? id;
  final String name;
  final String postnom;
  final String prenom;
  final String phone;
  final String gender;
  final String birthDate;
  final String commune;
  final String? email;
  final String? password;
  final String role;
  final String? photo;
  final String? token;

  User({
    this.id,
    required this.name,
    required this.postnom,
    required this.prenom,
    required this.phone,
    required this.gender,
    required this.birthDate,
    required this.commune,
    this.email,
    this.password,
    required this.role,
    this.photo,
    this.token,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'postnom': postnom,
      'prenom': prenom,
      'phone_number': phone,
      'gender': gender,
      'birth_date': birthDate,
      'commune': commune,
      'email': email,
      'password': password,
      'role': role,
      'photo': photo,
      'token': token,
    };
  }

 Map<String, String> toMultipartFields() {
    return {
      'name': name,
      'postnom': postnom,
      'prenom': prenom,
      'phone_number': phone,
      'gender': gender,
      'birth_date': birthDate,
      'commune': commune,
      'role': role,
      'photo' : ?photo,
      'email': email ?? '',
      if (password != null) 'password': password!,
      if (password != null) 'password_confirmation': password!,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'] ?? '',
      postnom: json['postnom'] ?? '',
      prenom: json['prenom'] ?? '',
      phone: json['phone_number'] ?? '',
      gender: json['gender'] ?? '',
      birthDate: json['birth_date'] ?? '',
      commune: json['commune'] ?? '',
      email: json['email']??'',
      role: json['role'] ?? 'passenger',
      photo: json['photo'],
      token: json['token'],
    );
  }
}