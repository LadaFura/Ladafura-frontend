import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ladafura_frontend_flutter/core/network/network_providers.dart';
import 'package:ladafura_frontend_flutter/features/collectes/models/agent_collecte_summary_model.dart';

final collectServiceProvider = Provider<CollectService>((ref) {
  final dio = ref.watch(dioProvider);
  return CollectService(dio);
});


class CollectService {
  final Dio dio;

  CollectService(this.dio);

  Future<List<AgentCollecteSummaryModel>> getAgentCollectes() async {
    final response = await dio.get('/agent/collectes');

    
if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      final List<AgentCollecteSummaryModel> agentCollectes = data.map((data)=> AgentCollecteSummaryModel.fromJson(data)).toList();


      return agentCollectes;
    } else {
      throw Exception('Failed to load agent collectes');
    }
   
}}