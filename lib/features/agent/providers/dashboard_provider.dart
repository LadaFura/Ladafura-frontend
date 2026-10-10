import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ladafura_frontend_flutter/core/network/network_providers.dart';
import 'package:ladafura_frontend_flutter/features/agent/models/agent_dashboard_response.dart';
import 'package:ladafura_frontend_flutter/features/agent/services/dashboard_service.dart';

final dashboardProviderService = Provider<DashboardService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return DashboardService(apiClient: apiClient);
},);



final dashboardAgentProvider = FutureProvider<AgentDashboardResponse>((ref) {
  final dashboardService = ref.watch(dashboardProviderService);

  return dashboardService.getAgentDashboard();
},);


