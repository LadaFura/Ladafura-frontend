import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ladafura_frontend_flutter/core/network/network_providers.dart';
import '../models/pharmacopee_avis_item_model.dart';
import '../models/pharmacopee_detail_model.dart';
import '../models/pharmacopee_eligibilite_avis_model.dart';
import '../models/pharmacopee_model.dart';
import '../models/pharmacopee_produit_item_model.dart';
import '../services/pharmacopee_service.dart';

final pharmacopeeServiceProvider = Provider<PharmacopeeService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PharmacopeeService(apiClient: apiClient);
});

final pharmacopeesListProvider =
    FutureProvider.autoDispose<List<PharmacopeeModel>>((ref) async {
  final service = ref.watch(pharmacopeeServiceProvider);
  return service.getPharmacopees();
});

/// Fournisseur complet de la fiche détaillée d'une pharmacopée (avec localisation et modes de retrait).
final pharmacopeeFullDetailProvider =
    FutureProvider.autoDispose.family<PharmacopeeDetailModel?, int>((ref, id) async {
  final service = ref.watch(pharmacopeeServiceProvider);
  return service.getPharmacopeeDetailModel(id);
});

/// Fournisseur des produits disponibles dans une pharmacopée donnée.
final pharmacopeeProduitsProvider =
    FutureProvider.autoDispose.family<List<PharmacopeeProduitItemModel>, int>((ref, id) async {
  final service = ref.watch(pharmacopeeServiceProvider);
  return service.getProduitsByPharmacopee(id, disponibleOnly: false);
});

/// Fournisseur des avis clients publiés pour une pharmacopée.
final pharmacopeeAvisProvider =
    FutureProvider.autoDispose.family<List<PharmacopeeAvisItemModel>, int>((ref, id) async {
  final service = ref.watch(pharmacopeeServiceProvider);
  return service.getAvisByPharmacopee(id);
});

/// Fournisseur d'éligibilité pour déposer/modifier un avis.
final pharmacopeeEligibiliteAvisProvider =
    FutureProvider.autoDispose.family<PharmacopeeEligibiliteAvisModel?, int>((ref, id) async {
  final service = ref.watch(pharmacopeeServiceProvider);
  return service.verifierEligibiliteAvis(id);
});

/// Fournisseur rétrocompatible
final pharmacopeeDetailProvider =
    FutureProvider.autoDispose.family<PharmacopeeModel?, int>((ref, id) async {
  final service = ref.watch(pharmacopeeServiceProvider);
  return service.getPharmacopeeDetail(id);
});

