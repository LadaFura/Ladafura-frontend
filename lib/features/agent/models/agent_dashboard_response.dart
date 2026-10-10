import 'package:ladafura_frontend_flutter/features/agent/models/agent_dashboard.dart';
import 'package:ladafura_frontend_flutter/features/agent/models/derni%C3%A8resCollectes_dashboard.dart';
import 'package:ladafura_frontend_flutter/features/agent/models/notifications_dashboard.dart';
import 'package:ladafura_frontend_flutter/features/agent/models/statistiques_dashboard.dart';

class AgentDashboardResponse {
  final AgentDashboard agent;
  final Statistiques statistiques;
  final Notifications notifications;
  final List<DerniereCollecte> dernieresCollectes;

  AgentDashboardResponse({
    required this.agent,
    required this.statistiques,
    required this.notifications,
    required this.dernieresCollectes,
  });

  factory AgentDashboardResponse.fromJson(Map<String, dynamic> json) {
    return AgentDashboardResponse(
      agent: AgentDashboard.fromJson(json['agent']),
      statistiques: Statistiques.fromJson(json['statistiques']),
      notifications: Notifications.fromJson(json['notifications']),
      dernieresCollectes: (json['dernieresCollectes'] as List)
          .map((e) => DerniereCollecte.fromJson(e))
          .toList(),
    );
  }
}