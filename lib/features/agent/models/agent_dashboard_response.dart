import 'package:ladafura_frontend_flutter/features/agent/models/agent_dashboard.dart';
import 'package:ladafura_frontend_flutter/features/agent/models/dernieres_collectes_dashboard.dart';
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
      agent: AgentDashboard.fromJson(
          Map<String, dynamic>.from(json['agent'] as Map? ?? {})),
      statistiques: Statistiques.fromJson(
          Map<String, dynamic>.from(json['statistiques'] as Map? ?? {})),
      notifications: Notifications.fromJson(
          Map<String, dynamic>.from(json['notifications'] as Map? ?? {})),
      dernieresCollectes: (json['dernieresCollectes'] as List? ?? [])
          .map((e) =>
              DerniereCollecte.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}