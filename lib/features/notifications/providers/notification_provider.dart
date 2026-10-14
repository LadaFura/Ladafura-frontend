import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/population_notification_model.dart';
import '../services/notification_api_service.dart';

/// Filtre actif pour la vue des notifications citoyen
enum NotificationFilter {
  toutes,
  nonLues,
  commandes,
  avis,
}

final notificationFilterProvider =
    StateProvider.autoDispose<NotificationFilter>((ref) => NotificationFilter.toutes);

/// Provider du nombre de notifications non lues (léger, auto-refresh ou manuellement invalidé)
final unreadNotificationCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final apiService = ref.watch(populationNotificationApiServiceProvider);
  try {
    return await apiService.getUnreadCount();
  } catch (_) {
    return 0;
  }
});

/// StateNotifier pour gérer la liste des notifications avec pagination et opérations dynamiques
class PopulationNotificationsNotifier
    extends StateNotifier<AsyncValue<List<PopulationNotificationModel>>> {
  final PopulationNotificationApiService _apiService;
  final Ref _ref;

  PopulationNotificationsNotifier(this._apiService, this._ref)
      : super(const AsyncValue.loading()) {
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    state = const AsyncValue.loading();
    try {
      final filter = _ref.read(notificationFilterProvider);
      bool? lue;
      String? type;

      if (filter == NotificationFilter.nonLues) {
        lue = false;
      } else if (filter == NotificationFilter.commandes) {
        type = 'COMMANDE_STATUT';
      } else if (filter == NotificationFilter.avis) {
        type = 'AVIS_NOUVEAU';
      }

      final items = await _apiService.getNotifications(lue: lue, type: type);
      state = AsyncValue.data(items);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    try {
      final filter = _ref.read(notificationFilterProvider);
      bool? lue;
      String? type;

      if (filter == NotificationFilter.nonLues) {
        lue = false;
      } else if (filter == NotificationFilter.commandes) {
        type = 'COMMANDE_STATUT';
      } else if (filter == NotificationFilter.avis) {
        type = 'AVIS_NOUVEAU';
      }

      final items = await _apiService.getNotifications(lue: lue, type: type);
      state = AsyncValue.data(items);
      _ref.invalidate(unreadNotificationCountProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> markAsRead(int id) async {
    try {
      await _apiService.markAsRead(id);
      final currentList = state.valueOrNull ?? [];
      state = AsyncValue.data(
        currentList.map((n) {
          if (n.id == id) {
            return n.copyWith(lue: true, dateLecture: DateTime.now());
          }
          return n;
        }).toList(),
      );
      _ref.invalidate(unreadNotificationCountProvider);
    } catch (_) {
      // Ignorer ou rafraîchir
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _apiService.markAllAsRead();
      final currentList = state.valueOrNull ?? [];
      state = AsyncValue.data(
        currentList.map((n) => n.copyWith(lue: true, dateLecture: DateTime.now())).toList(),
      );
      _ref.invalidate(unreadNotificationCountProvider);
    } catch (_) {
      // Ignorer
    }
  }

  Future<void> deleteNotification(int id) async {
    try {
      await _apiService.deleteNotification(id);
      final currentList = state.valueOrNull ?? [];
      state = AsyncValue.data(
        currentList.where((n) => n.id != id).toList(),
      );
      _ref.invalidate(unreadNotificationCountProvider);
    } catch (_) {
      // Ignorer
    }
  }
}

final populationNotificationsProvider = StateNotifierProvider.autoDispose<
    PopulationNotificationsNotifier,
    AsyncValue<List<PopulationNotificationModel>>>((ref) {
  final apiService = ref.watch(populationNotificationApiServiceProvider);
  return PopulationNotificationsNotifier(apiService, ref);
});

