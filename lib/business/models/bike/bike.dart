class Bike {
  final int? id;
  final String model;
  final String brand;
  final String matricule;
  final int ownerId;
  final int? bikerId;

  Bike({
    this.id,
    required this.model,
    required this.brand,
    required this.matricule,
    required this.ownerId,
    this.bikerId,
  });

  factory Bike.fromJson(Map<String, dynamic> json) {
    return Bike(
      id: json['id'],
      model: json['model'] ?? '',
      brand: json['brand'] ?? '',
      matricule: json['matricule'] ?? '',
      ownerId: json['owner_id'],
      bikerId: json['biker_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "model": model,
      "brand": brand,
      "matricule": matricule,
      "biker_id": bikerId,
    };
  }
}
