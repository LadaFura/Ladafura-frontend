
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ladafura_frontend_flutter/features/collectes/models/agent_collecte_summary_model.dart';
import 'package:ladafura_frontend_flutter/features/collectes/services/Collect_service.dart';




final collectProvider = FutureProvider<List<AgentCollecteSummaryModel>>((ref) async {
  final collectService = ref.watch(collectServiceProvider);
  print('Fetching agent collectes...');
  return collectService.getAgentCollectes();
});

