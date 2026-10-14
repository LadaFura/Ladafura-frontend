import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/agent_collecte_detail_model.dart';
import '../../collectes/models/agent_collecte_summary_response.dart';
import '../models/agent_dashboard_model.dart';
import '../models/agent_maladie_model.dart';
import '../models/agent_notification_response.dart';
import '../models/agent_plante_model.dart';
import '../models/agent_profile_model.dart';
import '../models/agent_recapitulatif_model.dart';
import '../models/agent_source_model.dart';

class AgentApiService {
  final ApiClient _client;

  AgentApiService({ApiClient? client}) : _client = client ?? ApiClient.instance;

  Dio get _dio => _client.dio;

  // ===========================================================================
  // DASHBOARD
  // ===========================================================================
  Future<AgentDashboardModel> getDashboard() async {
    final response = await _dio.get(ApiEndpoints.agentDashboardSummary);
    return AgentDashboardModel.fromJson(response.data as Map<String, dynamic>);
  }

  // ===========================================================================
  // COLLECTES
  // ===========================================================================
  Future<List<AgentCollecteSummaryResponse>> getCollectes({String? statut}) async {
    final Map<String, dynamic> queryParams = {};
    if (statut != null && statut.isNotEmpty && statut != 'TOUTES') {
      queryParams['statut'] = statut;
    }
    final response = await _dio.get(
      ApiEndpoints.agentCollectes,
      queryParameters: queryParams,
    );
    final data = response.data;
    if (data is List) {
      return data.map((json) => AgentCollecteSummaryResponse.fromJson(json)).toList();
    } else if (data is Map && data['content'] is List) {
      return (data['content'] as List)
          .map((json) => AgentCollecteSummaryResponse.fromJson(json))
          .toList();
    }
    return [];
  }

  Future<AgentCollecteDetailModel> getCollecteDetail(int id) async {
    final response = await _dio.get(ApiEndpoints.agentCollecteDetail(id.toString()));
    return AgentCollecteDetailModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<AgentCollecteDetailModel> createDraft({
    String? description,
    String? dateCollecte,
    int? sourceId,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.agentCollectesDraft,
      data: {
        if (description != null) 'description': description,
        if (dateCollecte != null) 'dateCollecte': dateCollecte,
        if (sourceId != null) 'sourceId': sourceId,
      },
    );
    return AgentCollecteDetailModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<AgentCollecteDetailModel> updateCollecte(
    int id, {
    String? description,
    String? dateCollecte,
    int? sourceId,
  }) async {
    final response = await _dio.put(
      ApiEndpoints.agentCollecteDetail(id.toString()),
      data: {
        if (description != null) 'description': description,
        if (dateCollecte != null) 'dateCollecte': dateCollecte,
        if (sourceId != null) 'sourceId': sourceId,
      },
    );
    return AgentCollecteDetailModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteCollecte(int id) async {
    await _dio.delete(ApiEndpoints.agentCollecteDetail(id.toString()));
  }

  // ===========================================================================
  // PLANTES
  // ===========================================================================
  Future<List<AgentPlanteModel>> searchPlantes({String? search}) async {
    final response = await _dio.get(
      ApiEndpoints.agentPlantes,
      queryParameters: search != null && search.isNotEmpty ? {'search': search} : null,
    );
    final data = response.data;
    if (data is List) {
      return data.map((e) => AgentPlanteModel.fromJson(e)).toList();
    } else if (data is Map && data['content'] is List) {
      return (data['content'] as List)
          .map((e) => AgentPlanteModel.fromJson(e))
          .toList();
    }
    return [];
  }

  Future<AgentPlanteModel> createPlante({
    required String nomScientifique,
    String? description,
    String? nomVernaculaire,
    String? langueVernaculaire,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.agentPlantes,
      data: {
        'nomScientifique': nomScientifique,
        if (description != null && description.trim().isNotEmpty)
          'description': description.trim(),
        if (nomVernaculaire != null && nomVernaculaire.trim().isNotEmpty)
          'nomsVernaculaires': [
            {
              'nom': nomVernaculaire.trim(),
              'langue': (langueVernaculaire != null && langueVernaculaire.trim().isNotEmpty)
                  ? langueVernaculaire.trim()
                  : 'Bambara',
              'pays': 'Mali',
            },
          ],
      },
    );
    return AgentPlanteModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> associerPlanteACollecte({
    required int collecteId,
    required int planteId,
  }) async {
    await _dio.post('${ApiEndpoints.agentCollectes}/$collecteId/plantes/$planteId');
  }

  // ===========================================================================
  // MALADIES & SYMPTÔMES
  // ===========================================================================
  Future<List<AgentMaladieModel>> searchMaladies({String? search}) async {
    final response = await _dio.get(
      ApiEndpoints.agentMaladies,
      queryParameters: search != null && search.isNotEmpty ? {'search': search} : null,
    );
    final data = response.data;
    if (data is List) {
      return data.map((e) => AgentMaladieModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<AgentMaladieModel> createMaladie({
    required String nom,
    String? description,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.agentMaladies,
      data: {
        'nom': nom,
        if (description != null) 'description': description,
      },
    );
    return AgentMaladieModel.fromJson(response.data as Map<String, dynamic>);
  }

  // ===========================================================================
  // CONNAISSANCES TRADITIONNELLES
  // ===========================================================================
  Future<void> enregistrerConnaissance({
    required int collecteId,
    required int planteId,
    required String usageRapporte,
    required String partieUtilisee,
    required String preparation,
    String? precaution,
    int? sourceId,
    List<int>? maladieIds,
  }) async {
    await _dio.post(
      ApiEndpoints.agentConnaissances,
      data: {
        'collecteId': collecteId,
        'planteId': planteId,
        'usageRapporte': usageRapporte,
        'partieUtilisee': partieUtilisee,
        'preparation': preparation,
        if (precaution != null) 'precaution': precaution,
        if (sourceId != null) 'sourceId': sourceId,
        if (maladieIds != null && maladieIds.isNotEmpty) 'maladieIds': maladieIds,
      },
    );
  }

  // ===========================================================================
  // SOURCES (TRADIPRATICIENS / HERBORISTES)
  // ===========================================================================
  Future<List<AgentSourceModel>> getSources({String? search}) async {
    final response = await _dio.get(
      ApiEndpoints.agentSources,
      queryParameters: search != null && search.isNotEmpty ? {'search': search} : null,
    );
    final data = response.data;
    if (data is List) {
      return data.map((e) => AgentSourceModel.fromJson(e)).toList();
    } else if (data is Map && data['content'] is List) {
      return (data['content'] as List)
          .map((e) => AgentSourceModel.fromJson(e))
          .toList();
    }
    return [];
  }

  Future<AgentSourceModel> createSource({
    required String nom,
    String? prenom,
    String? telephone,
    String? adresse,
    String? specialite,
    int? anneesExperience,
    String role = 'THERAPEUTE',
  }) async {
    final response = await _dio.post(
      ApiEndpoints.agentSources,
      data: {
        'nom': nom,
        if (prenom != null) 'prenom': prenom,
        if (telephone != null) 'telephone': telephone,
        if (adresse != null) 'adresse': adresse,
        if (specialite != null) 'specialite': specialite,
        if (anneesExperience != null) 'anneesExperience': anneesExperience,
        'role': role,
      },
    );
    return AgentSourceModel.fromJson(response.data as Map<String, dynamic>);
  }

  // ===========================================================================
  // LOCALISATION
  // ===========================================================================
  Future<void> enregistrerLocalisation({
    required int collecteId,
    required String region,
    String? cercle,
    String? commune,
    String? localite,
    double? latitude,
    double? longitude,
  }) async {
    await _dio.post(
      '${ApiEndpoints.agentCollectes}/$collecteId/localisation',
      data: {
        'region': region,
        if (cercle != null) 'cercle': cercle,
        if (commune != null) 'commune': commune,
        if (localite != null) 'localite': localite,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      },
    );
  }

  // ===========================================================================
  // MÉDIAS (PHOTO / AUDIO)
  // ===========================================================================
  Future<void> uploadPhoto({required int collecteId, required File file}) async {
    final fileName = file.path.split('/').last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path, filename: fileName),
    });
    await _dio.post(
      '${ApiEndpoints.agentCollectes}/$collecteId/medias/photo',
      data: formData,
    );
  }

  Future<void> uploadAudio({required int collecteId, required File file}) async {
    final fileName = file.path.split('/').last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path, filename: fileName),
    });
    await _dio.post(
      '${ApiEndpoints.agentCollectes}/$collecteId/medias/audio',
      data: formData,
    );
  }

  // ===========================================================================
  // RÉCAPITULATIF & SOUMISSION
  // ===========================================================================
  Future<AgentCollecteRecapitulatifModel> getRecapitulatif(int collecteId) async {
    final response = await _dio.get(
      ApiEndpoints.agentCollecteRecapitulatif(collecteId.toString()),
    );
    return AgentCollecteRecapitulatifModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<void> soumettreCollecte(int collecteId) async {
    await _dio.post(ApiEndpoints.agentCollecteSoumettre(collecteId.toString()));
  }

  // ===========================================================================
  // PROFIL AGENT
  // ===========================================================================
  Future<AgentProfileModel> getProfile() async {
    final response = await _dio.get(ApiEndpoints.agentProfile);
    return AgentProfileModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<AgentProfileModel> updateProfile({
    required String nom,
    required String prenom,
    String? telephone,
    String? zoneCouverture,
  }) async {
    final response = await _dio.put(
      ApiEndpoints.agentProfile,
      data: {
        'nom': nom.trim(),
        'prenom': prenom.trim(),
        if (telephone != null && telephone.trim().isNotEmpty)
          'telephone': telephone.trim(),
        if (zoneCouverture != null && zoneCouverture.trim().isNotEmpty)
          'zoneCouverture': zoneCouverture.trim(),
      },
    );
    return AgentProfileModel.fromJson(response.data as Map<String, dynamic>);
  }

  // ===========================================================================
  // NOTIFICATIONS AGENT
  // ===========================================================================
  Future<List<AgentNotificationResponse>> getNotifications({
    bool? lue,
    String? type,
  }) async {
    final queryParams = <String, dynamic>{
      'size': 50,
      if (lue != null) 'lue': lue,
      if (type != null && type.isNotEmpty) 'type': type,
    };
    final response = await _dio.get(
      ApiEndpoints.agentNotifications,
      queryParameters: queryParams,
    );
    final data = response.data;
    if (data is List) {
      return data
          .map((e) =>
              AgentNotificationResponse.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (data is Map && data['content'] is List) {
      return (data['content'] as List)
          .map((e) =>
              AgentNotificationResponse.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<AgentNotificationResponse> markNotificationAsRead(int id) async {
    final response =
        await _dio.patch('${ApiEndpoints.agentNotifications}/$id/read');
    return AgentNotificationResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<void> markAllNotificationsAsRead() async {
    await _dio.post('${ApiEndpoints.agentNotifications}/read-all');
  }

  Future<void> deleteNotification(int id) async {
    await _dio.delete('${ApiEndpoints.agentNotifications}/$id');
  }
}

