class AppNotification {
  final int? id;
  final String title;
  final String message;
  final String type;
  final int? race_id;
  final int passenger_id;
  final bool isRead;

  AppNotification({
    this.id,
    required this.title,
    required this.message,
    required this.type,
    this.race_id,
    required this.passenger_id,
    this.isRead = false,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      title: json['title'],
      message: json['message'],
      type: json['type'],
      race_id: json['race_id'],
      passenger_id: json['passenger'],
    );
  }
}