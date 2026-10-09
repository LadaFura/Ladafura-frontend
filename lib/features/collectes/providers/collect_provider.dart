import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ladafura_frontend_flutter/core/network/network_providers.dart';
import 'package:ladafura_frontend_flutter/features/collectes/models/agent_collecte_summary_response.dart';
import 'package:ladafura_frontend_flutter/features/collectes/services/Collect_service.dart';

final collectServiceProvider = Provider<CollectService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return CollectService(apiClient: apiClient);
});



final collectListProvider = FutureProvider<List<AgentCollecteSummaryResponse>>((ref) {
  final collectService= ref.watch(collectServiceProvider);
  return collectService.getAgentCollectes();
  
},);


