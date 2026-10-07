import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ladafura_frontend_flutter/core/services/services_providers.dart';
import 'package:ladafura_frontend_flutter/core/services/storage_service.dart';

/// Notifier gérant la liste dynamique des recherches récentes.
/// Sauvegarde automatique dans SharedPreferences via StorageService.
class RecentSearchesNotifier extends StateNotifier<List<String>> {
  final StorageService _storageService;

  RecentSearchesNotifier(this._storageService)
      : super(_storageService.getRecentSearches());

  /// Ajoute un terme en tête de liste et persiste l'état
  Future<void> addSearch(String term) async {
    final clean = term.trim();
    if (clean.isEmpty) return;
    await _storageService.addRecentSearch(clean);
    state = _storageService.getRecentSearches();
  }

  /// Supprime un terme précis et persiste l'état
  Future<void> removeSearch(String term) async {
    await _storageService.removeRecentSearch(term);
    state = _storageService.getRecentSearches();
  }

  /// Vide l'historique complet
  Future<void> clearAll() async {
    await _storageService.saveRecentSearches([]);
    state = [];
  }
}

/// Provider d'accès à l'historique dynamique des recherches récentes.
final recentSearchesProvider =
    StateNotifierProvider<RecentSearchesNotifier, List<String>>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return RecentSearchesNotifier(storageService);
});
