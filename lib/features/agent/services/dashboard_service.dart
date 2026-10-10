import 'package:ladafura_frontend_flutter/core/constants/api_endpoints.dart';
import 'package:ladafura_frontend_flutter/core/network/api_client.dart';
import 'package:ladafura_frontend_flutter/features/agent/models/agent_dashboard.dart';
import 'package:ladafura_frontend_flutter/features/agent/models/agent_dashboard_response.dart';

class DashboardService {
  ApiClient _apiClient;

  DashboardService({required ApiClient apiClient}) : _apiClient=apiClient;


  Future<AgentDashboardResponse> getAgentDashboard() async{
    final response =await _apiClient.get(ApiEndpoints.agentDashboard,);
    if (!response.isSuccess || response.data==null) {
      throw Exception('Aucun statistique disponible pour cet agent');
    }

    final data = response.data;

    return  AgentDashboardResponse.fromJson(data);
  }
}