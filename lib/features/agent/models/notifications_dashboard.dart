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
      total: (json['total'] as num?)?.toInt() ?? 0,
      nonLues: (json['nonLues'] as num?)?.toInt() ?? 0,
      dernieresNotifications: (json['dernieresNotifications'] as List? ?? [])
          .map((item) => AgentNotificationResponse.fromJson(
              Map<String, dynamic>.from(item as Map)))
          .toList(),
    );
  }
}
