import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ladafura_frontend_flutter/core/constants/api_endpoints.dart';
import 'package:ladafura_frontend_flutter/core/network/api_client.dart';
import 'package:ladafura_frontend_flutter/core/network/network_providers.dart';
import 'package:ladafura_frontend_flutter/features/collectes/models/agent_collecte_summary_model.dart';
import 'package:ladafura_frontend_flutter/features/collectes/models/agent_collecte_summary_response.dart';

class CollectService {
  final ApiClient _apiClient;

  CollectService({required ApiClient apiClient}): _apiClient = apiClient;

  Future<List<AgentCollecteSummaryResponse>> getAgentCollectes() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.agentCollectes,
    );

    
if (!response.isSuccess && response.data == null) {
      throw Exception('Failed to fetch agent collectes');
    }


final data = response.data;
    if (data == null) {
      throw Exception('Response data is null');
    }

    final content = data['content'] as List<dynamic>?;
    if (content == null) {
      throw Exception('Content field is missing in the response');
    }

    return content
        .map((json) => AgentCollecteSummaryResponse.fromJson(json))
        .toList();

   
  }}