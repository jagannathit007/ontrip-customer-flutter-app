class NotificationModel {
  final String? id;
  final String? title;
  final String? message;
  final String? type;
  final bool? isRead;
  final DateTime? createdAt;
  final Map<String, dynamic>? data;

  NotificationModel({this.id, this.title, this.message, this.type, this.isRead, this.createdAt, this.data});

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'] as String?,
      title: json['title'] as String?,
      message: json['message'] as String?,
      type: json['type'] as String?,
      isRead: json['isRead'] as bool? ?? false,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'_id': id, 'title': title, 'message': message, 'type': type, 'isRead': isRead, 'createdAt': createdAt?.toIso8601String(), 'data': data};
  }
}

class NotificationResponse {
  final bool? success;
  final String? message;
  final List<NotificationModel>? notifications;
  final int? unreadCount;

  NotificationResponse({this.success, this.message, this.notifications, this.unreadCount});

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    return NotificationResponse(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      notifications: json['data'] != null && json['data']['notifications'] != null
          ? (json['data']['notifications'] as List).map((e) => NotificationModel.fromJson(e as Map<String, dynamic>)).toList()
          : null,
      unreadCount: json['data'] != null ? json['data']['unreadCount'] as int? : null,
    );
  }
}
