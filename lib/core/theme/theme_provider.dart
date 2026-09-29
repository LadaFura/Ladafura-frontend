import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Gestionnaire d'état Riverpod pour le mode de thème (Clair / Sombre / Système)
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system);

  /// Basculer entre thème clair et sombre.
  /// Si [currentIsDark] est fourni, bascule de manière infaillible vers l'opposé du thème affiché.
  void toggleTheme({bool? currentIsDark}) {
    if (currentIsDark != null) {
      state = currentIsDark ? ThemeMode.light : ThemeMode.dark;
    } else {
      if (state == ThemeMode.dark) {
        state = ThemeMode.light;
      } else {
        state = ThemeMode.dark;
      }
    }
  }

  /// Définir un mode de thème spécifique
  void setThemeMode(ThemeMode mode) {
    state = mode;
  }
}

/// Provider global pour le thème de l'application LADAFURA
final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});
