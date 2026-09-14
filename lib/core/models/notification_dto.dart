class NotificationDto {
  final String id;
  final String title;
  final String message;
  final bool isUnread;
  final DateTime createdAt;
  final String? actionRoute;

  NotificationDto({
    required this.id,
    required this.title,
    required this.message,
    required this.isUnread,
    required this.createdAt,
    this.actionRoute,
  });

  factory NotificationDto.fromJson(Map<String, dynamic> json) {
    return NotificationDto(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      isUnread: json['isUnread'] ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      actionRoute: json['actionRoute'],
    );
  }
}