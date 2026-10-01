class Biker {
  final int id;
  final int userId;
  final bool hasBike;

  Biker({required this.id, required this.userId, this.hasBike = false});

  factory Biker.fromJson(Map<String, dynamic> json) {
    return Biker(
      id: int.parse(json['id'].toString()),
      userId: int.parse(
        (json['user_id'] ?? (json['user'] as Map?)?['id']).toString(),
      ),
      hasBike: json['bike'] != null,
    );
  }
}
