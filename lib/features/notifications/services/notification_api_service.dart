import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/network_providers.dart';
import '../models/population_notification_model.dart';

final populationNotificationApiServiceProvider =
    Provider<PopulationNotificationApiService>((ref) {
  final dio = ref.watch(dioProvider);
  return PopulationNotificationApiService(dio);
});

class PopulationNotificationApiService {
  final Dio _dio;

  PopulationNotificationApiService(this._dio);

  /// Récupère la liste paginée des notifications.
  Future<List<PopulationNotificationModel>> getNotifications({
    bool? lue,
    String? type,
    int page = 0,
    int size = 20,
  }) async {
    final Map<String, dynamic> queryParams = {
      'page': page,
      'size': size,
    };
    if (lue != null) queryParams['lue'] = lue;
    if (type != null && type.isNotEmpty) queryParams['type'] = type;

    final response = await _dio.get(
      ApiEndpoints.populationNotifications,
      queryParameters: queryParams,
    );

    if (response.statusCode == 200 && response.data != null) {
      final data = response.data;
      final List<dynamic> items;
      if (data is Map<String, dynamic> && data['content'] is List) {
        items = data['content'] as List;
      } else if (data is List) {
        items = data;
      } else {
        items = [];
      }

      return items
          .map((item) => PopulationNotificationModel.fromJson(
              item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Récupère le compteur de notifications non lues.
  Future<int> getUnreadCount() async {
    final response = await _dio.get('${ApiEndpoints.populationNotifications}/unread-count');
    if (response.statusCode == 200 && response.data != null) {
      if (response.data is Map<String, dynamic>) {
        final count = response.data['count'];
        if (count is int) return count;
        if (count is num) return count.toInt();
      }
    }
    return 0;
  }

  /// Récupère les statistiques de notification.
  Future<PopulationNotificationStatsModel> getStats() async {
    final response = await _dio.get('${ApiEndpoints.populationNotifications}/stats');
    if (response.statusCode == 200 && response.data != null) {
      return PopulationNotificationStatsModel.fromJson(
          response.data as Map<String, dynamic>);
    }
    return const PopulationNotificationStatsModel();
  }

  /// Marque une notification comme lue.
  Future<PopulationNotificationModel?> markAsRead(int id) async {
    final response = await _dio.patch(
      '${ApiEndpoints.populationNotifications}/$id/read',
    );
    if (response.statusCode == 200 && response.data != null) {
      return PopulationNotificationModel.fromJson(
          response.data as Map<String, dynamic>);
    }
    return null;
  }

  /// Marque toutes les notifications comme lues.
  Future<void> markAllAsRead() async {
    await _dio.post('${ApiEndpoints.populationNotifications}/read-all');
  }

  /// Supprime une notification par son identifiant.
  Future<void> deleteNotification(int id) async {
    await _dio.delete('${ApiEndpoints.populationNotifications}/$id');
  }

  /// Nettoie toutes les notifications déjà lues.
  Future<void> clearAllReadNotifications() async {
    await _dio.delete('${ApiEndpoints.populationNotifications}/clear-read');
  }
}

