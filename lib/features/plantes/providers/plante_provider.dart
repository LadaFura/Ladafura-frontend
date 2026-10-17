import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ladafura_frontend_flutter/core/network/network_providers.dart';
import '../../home/providers/home_discovery_provider.dart';
import '../../home/services/home_service.dart';
import '../models/plante_model.dart';
import '../services/plante_service.dart';

import '../models/produit_detail_model.dart';

import '../models/produit_model.dart';

final planteServiceProvider = Provider<PlanteService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PlanteService(apiClient: apiClient);
});

final plantesListProvider =
    FutureProvider.autoDispose<List<PopulationPlanteDetailModel>>((ref) async {
  final service = ref.watch(planteServiceProvider);
  return service.getPlantes();
});

final planteDetailProvider = FutureProvider.autoDispose
    .family<PopulationPlanteDetailModel?, int>((ref, id) async {
  final service = ref.watch(planteServiceProvider);
  final detail = await service.getPlanteDetail(id);
  if (detail != null) {
    HomeService.recordLocalPlantConsultation(id);
    ref.invalidate(popularPlantesProvider);
  }
  return detail;
});

final produitDetailProvider = FutureProvider.autoDispose
    .family<ProduitDetailModel?, int>((ref, id) async {
  final service = ref.watch(planteServiceProvider);
  return service.getProduitDetail(id);
});

final produitsByPlanteProvider = FutureProvider.autoDispose
    .family<List<ProduitModel>, int>((ref, id) async {
  final service = ref.watch(planteServiceProvider);
  return service.getProduitsByPlante(id);
});
