class AppNotification {
  final int id;
  final String title;
  final String message;
  final String? readAt;
  final String? assignedAt;
  bool get isRead => readAt != null;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    this.readAt,
    this.assignedAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      readAt: json['read_at'],
      assignedAt: json['assigned_at'],
    );
  }
}