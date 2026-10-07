import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/network_providers.dart';
import '../models/commande_model.dart';
import '../models/mode_retrait_model.dart';
import '../models/paiement_model.dart';

final commandeServiceProvider = Provider<CommandeService>((ref) {
  final dio = ref.watch(dioProvider);
  return CommandeService(dio);
});

/// Service central gérant les commandes, retraits et règlements financiers.
class CommandeService {
  final Dio _dio;

  CommandeService(this._dio);

  /// Récupère les options de mise à disposition (retrait/livraison) d'une pharmacopée.
  Future<PharmacopeeRetraitOptionsModel> getOptionsRetrait(
      int pharmacopeeId) async {
    final response = await _dio.get(
      ApiEndpoints.populationRetraitPharmacopee(pharmacopeeId.toString()),
    );
    if (response.statusCode == 200 && response.data != null) {
      return PharmacopeeRetraitOptionsModel.fromJson(
          response.data as Map<String, dynamic>);
    }
    throw Exception("Impossible de charger les options de retrait");
  }

  /// Calcule et génère le devis/récapitulatif chiffré avant confirmation.
  Future<CommandeRecapitulatifModel> getRecapitulatif({
    required int pharmacopeeId,
    required int modeRetraitId,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.populationCommandesRecapitulatif,
      data: {
        'pharmacopeeId': pharmacopeeId,
        'modeRetraitId': modeRetraitId,
      },
    );
    if (response.statusCode == 200 && response.data != null) {
      return CommandeRecapitulatifModel.fromJson(
          response.data as Map<String, dynamic>);
    }
    throw Exception("Impossible de générer le récapitulatif");
  }

  /// Passe et confirme définitivement la commande dans le backend.
  Future<CommandeDetailModel> passerCommande({
    required int pharmacopeeId,
    required int modeRetraitId,
    String? adresseLivraison,
    String? notes,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.populationCommandes,
      data: {
        'pharmacopeeId': pharmacopeeId,
        'modeRetraitId': modeRetraitId,
        'adresseLivraison': adresseLivraison,
        'notes': notes,
      },
    );
    if ((response.statusCode == 200 || response.statusCode == 201) &&
        response.data != null) {
      return CommandeDetailModel.fromJson(
          response.data as Map<String, dynamic>);
    }
    throw Exception("Échec de création de la commande");
  }

  /// Récupère l'historique paginé des commandes de l'utilisateur.
  Future<List<CommandeSummaryModel>> getHistoriqueCommandes({
    String? statut,
  }) async {
    final queryParams = <String, dynamic>{
      'page': 0,
      'size': 30,
    };
    if (statut != null && statut.isNotEmpty) {
      queryParams['statut'] = statut;
    }

    final response = await _dio.get(
      ApiEndpoints.populationCommandes,
      queryParameters: queryParams,
    );
    if (response.statusCode == 200 && response.data != null) {
      final List items = response.data['content'] is List
          ? response.data['content']
          : (response.data is List ? response.data : []);
      return items
          .map((e) =>
              CommandeSummaryModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Récupère le détail complet d'une commande par son ID.
  Future<CommandeDetailModel> getCommandeDetail(int commandeId) async {
    final response = await _dio.get(
      ApiEndpoints.populationCommandeDetail(commandeId.toString()),
    );
    if (response.statusCode == 200 && response.data != null) {
      return CommandeDetailModel.fromJson(
          response.data as Map<String, dynamic>);
    }
    throw Exception("Commande introuvable");
  }

  /// Annule une commande en cours (si statut EN_ATTENTE ou CONFIRMEE).
  Future<CommandeDetailModel> annulerCommande(int commandeId) async {
    final response = await _dio.post(
      ApiEndpoints.populationCommandeAnnuler(commandeId.toString()),
    );
    if (response.statusCode == 200 && response.data != null) {
      return CommandeDetailModel.fromJson(
          response.data as Map<String, dynamic>);
    }
    throw Exception("Impossible d'annuler la commande");
  }

  /// Récupère la liste des méthodes de paiement configurées.
  Future<List<MethodePaiementModel>> getMethodesPaiement() async {
    final response = await _dio.get(ApiEndpoints.populationPaiementsMethodes);
    if (response.statusCode == 200 && response.data != null) {
      final List items = response.data is List ? response.data : [];
      return items
          .map((e) =>
              MethodePaiementModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Effectue le règlement d'une commande (Mobile Money, Espèces ou Carte).
  Future<PaiementResponseModel> payerCommande({
    required int commandeId,
    required String methode, // 'MOBILE_MONEY', 'CASH', 'CARTE_BANCAIRE'
    String? operateur, // 'ORANGE_MONEY', 'MOOV_MONEY', 'WAVE'
    String? telephoneMobileMoney,
    String? referenceTransaction,
    bool simulerSucces = true,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.populationPaiements,
      data: {
        'commandeId': commandeId,
        'methode': methode,
        'operateur': operateur,
        'telephoneMobileMoney': telephoneMobileMoney,
        'referenceTransaction': referenceTransaction,
        'simulerSucces': simulerSucces,
      },
    );
    if (response.statusCode == 200 && response.data != null) {
      return PaiementResponseModel.fromJson(
          response.data as Map<String, dynamic>);
    }
    throw Exception("Échec du paiement");
  }

  /// Compatibilité ascendante avec l'ancien code éventuel
  Future<List<CommandeModel>> fetchMesCommandes() async {
    final summaries = await getHistoriqueCommandes();
    return summaries
        .map((s) => CommandeModel(
              id: s.id,
              numeroCommande: s.numero,
              statut: s.statut,
              montantTotal: s.montantTotal,
              dateCreation: s.dateCommande,
              items: [],
            ))
        .toList();
  }
}
