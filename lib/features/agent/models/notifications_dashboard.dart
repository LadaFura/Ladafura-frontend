import 'package:ladafura_frontend_flutter/features/agent/models/agent_notification_response.dart';

class Notifications {
  final int total;
  final int nonLues;
  final List<AgentNotificationResponse> dernieresNotifications;

  Notifications({
    required this.total,
    required this.nonLues,
    required this.dernieresNotifications,
  });

  factory Notifications.fromJson(Map<String, dynamic> json) {
    return Notifications(
      total: json['total'],
      nonLues: json['nonLues'],
      dernieresNotifications: (json['dernieresNotifications'] as List)
          .map((item) => AgentNotificationResponse.fromJson(item))
          .toList(),
    );
  }
}
