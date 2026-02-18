class Biker {
  final int id;
  final int userId;

  Biker({
    required this.id,
    required this.userId,
  });

  factory Biker.fromJson(Map<String, dynamic> json) {
    return Biker(
      id: json['id'],
      userId: json['user_id'],
    );
  }
}
