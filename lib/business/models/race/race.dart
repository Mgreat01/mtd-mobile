class Race {
  final int id;
  final String name;
  final String date;
  final String startingPoint;
  final String destination;
  final String status;
  final int bikerId;
  final int clientId;
  final int? idPriceList;
  final int? priceListId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  Race({
    required this.id,
    required this.name,
    required this.date,
    required this.startingPoint,
    required this.destination,
    required this.status,
    required this.bikerId,
    required this.clientId,
    this.idPriceList,
    this.priceListId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory Race.fromJson(Map<String, dynamic> json) {
    return Race(
      id: json['id'] as int,
      name: json['name'] ?? '',
      date: json['date']?? '',
      startingPoint: json['starting_point'] ?? '',
      destination: json['destination'] ?? '',
      status: json['status'] ?? 'pending',
      bikerId: json['biker_id'] as int,
      clientId: json['client_id'] as int,
      idPriceList: json['id_Price_list'],
      priceListId: json['price_list_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'date': date,
      'starting_point': startingPoint,
      'destination': destination,
      'status': status,
      'biker_id': bikerId,
      'client_id': clientId,
      'id_Price_list': idPriceList,
      'price_list_id': priceListId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }
}