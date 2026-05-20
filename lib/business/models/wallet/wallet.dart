class Wallet {
 final int? id;
 final double balance;
 final int? userId;
 final String? pin;
 final DateTime? createdAt;
 final DateTime? updatedAt;

 Wallet({
  this.id,
  required this.balance,
  this.userId,
  this.pin,
  this.createdAt,
  this.updatedAt,
 });

 factory Wallet.fromJson(Map<String, dynamic> json) {
  return Wallet(
   id: json['id'],
   balance: double.tryParse(json['balance'].toString()) ?? 0.0,
   userId: json['user_id'],
   pin: json['pin'],
   createdAt: json['created_at'] != null
       ? DateTime.parse(json['created_at'])
       : null,
   updatedAt: json['updated_at'] != null
       ? DateTime.parse(json['updated_at'])
       : null,
  );
 }

 Map<String, dynamic> toJson() {
  return {
   if (id != null) 'id': id,
   'balance': balance,
   'user_id': userId,
   'pin': pin,
  };
 }

 Wallet copyWith({
  int? id,
  double? balance,
  int? userId,
  String? pin,
 }) {
  return Wallet(
   id: id ?? this.id,
   balance: balance ?? this.balance,
   userId: userId ?? this.userId,
   pin: pin ?? this.pin,
  );
 }
}