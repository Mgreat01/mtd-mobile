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

  User copyWith({String? password, String? token, String? photo}) => User(
    id: id, name: name, postnom: postnom, prenom: prenom, phone: phone,
    gender: gender, birthDate: birthDate, commune: commune, email: email,
    password: password ?? this.password, role: role, photo: photo ?? this.photo,
    token: token ?? this.token,
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'postnom': postnom, 'prenom': prenom,
    'phone_number': phone, 'gender': gender, 'birth_date': birthDate,
    'commune': commune, 'email': email, 'password': password,
    'role': role, 'photo': photo, 'token': token,
  };

  Map<String, String> toMultipartFields() => {
    'name': name,
    'postnom': postnom,
    'prenom': prenom,
    'phone_number': phone,
    'gender': gender,
    'birth_date': birthDate,
    'commune': commune,
    'role': role,
    'email': email ?? '',
    if (password != null) 'password': password!,
    if (password != null) 'password_confirmation': password!,
  };

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'], name: json['name'] ?? '', postnom: json['postnom'] ?? '',
    prenom: json['prenom'] ?? '', phone: json['phone_number'] ?? '',
    gender: json['gender'] ?? '', birthDate: json['birth_date']?.toString() ?? '',
    commune: json['commune'] ?? '', email: json['email']?.toString(),
    role: json['role'] ?? 'passenger', photo: json['photo']?.toString(),
    token: json['token']?.toString(),
  );
}
