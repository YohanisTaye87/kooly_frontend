class NotificationModel {
  final String title;
  final String userId;
  final String body;
  final String? token;
  final DateTime createdAt;
  final DateTime updatedAt;

  NotificationModel({
    required this.title,
    required this.userId,
    required this.body,
    this.token,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      title: json['title'],
      userId: json['userId'],
      body: json['body'],
      token: json['token'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now().add(const Duration(hours: 3)),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now().add(const Duration(hours: 3)),
    );
  }
}
