import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Notifier officiel gérant l'index de l'onglet actif dans la barre de navigation LADAFURA (0 à 4)
class NavigationNotifier extends Notifier<int> {
  @override
  int build() => 0;

  /// Modifie l'onglet de navigation actif
  void setIndex(int newIndex) {
    if (newIndex >= 0 && newIndex <= 4 && state != newIndex) {
      state = newIndex;
    }
  }

  /// Raccourci vers l'onglet Accueil (0)
  void goToHome() => state = 0;

  /// Raccourci vers l'onglet Carte (1)
  void goToMap() => state = 1;

  /// Raccourci vers l'onglet Recherche (2)
  void goToSearch() => state = 2;

  /// Raccourci vers l'onglet Panier (3)
  void goToCart() => state = 3;

  /// Raccourci vers l'onglet Profil (4)
  void goToProfile() => state = 4;
}

/// Provider Riverpod de l'index de navigation actif
final navigationIndexProvider =
    NotifierProvider<NavigationNotifier, int>(NavigationNotifier.new);

/// Provider Riverpod du nombre d'articles dans le panier
final cartBadgeCountProvider = StateProvider<int>((ref) => 2);
