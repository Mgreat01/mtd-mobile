class Race {
  final int id;
  final String name;
  final String date;
  final String startingPoint;
  final String destination;
  final double? startLat;
  final double? startLng;
  final double? endLat;
  final double? endLng;

  final String status;
  final String? pinCode;
  final int? bikerId;
  final int clientId;
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
    this.startLat,
    this.startLng,
    this.endLat,
    this.endLng,
    required this.status,
    this.pinCode,
    this.bikerId,
    required this.clientId,
    this.priceListId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory Race.fromJson(Map<String, dynamic> json) {
    return Race(
      id: json['id'] as int,
      name: json['name'] ?? '',
      date: json['date'] ?? '',
      startingPoint: json['starting_point'] ?? '',
      destination: json['destination'] ?? '',
      startLat: json['start_lat'] != null ? double.parse(json['start_lat'].toString()) : null,
      startLng: json['start_lng'] != null ? double.parse(json['start_lng'].toString()) : null,
      endLat: json['end_lat'] != null ? double.parse(json['end_lat'].toString()) : null,
      endLng: json['end_lng'] != null ? double.parse(json['end_lng'].toString()) : null,

      status: json['status'] ?? 'pending',
      pinCode: json['pin_code']?.toString(),
      bikerId: json['biker_id'] != null ? json['biker_id'] as int : null,
      clientId: json['client_id'] as int,
      priceListId: json['price_list_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'date': date,
      'starting_point': startingPoint,
      'destination': destination,
      'lat_start': startLat,
      'lng_start': startLng,
      'end_lat': endLat,
      'end_lng': endLng,
      'status': status,
      'pin_code': pinCode,
      'biker_id': bikerId,
      'client_id': clientId,
      'price_list_id': priceListId,
    };
  }
}