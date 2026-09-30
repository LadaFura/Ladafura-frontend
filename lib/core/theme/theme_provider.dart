import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';

/// Gestionnaire d'état Riverpod pour le mode de thème (Clair / Sombre / Système).
///
/// Charge automatiquement le thème depuis le stockage persistant [StorageService],
/// avec prise en compte du thème du système par défaut ([ThemeMode.system]),
/// et persiste tout changement utilisateur.
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final StorageService? _storageService;

  ThemeModeNotifier([StorageService? storageService])
      : _storageService = storageService ?? _resolveStorage(),
        super(_resolveInitialTheme(storageService ?? _resolveStorage()));

  static StorageService? _resolveStorage() {
    try {
      return StorageService.instance;
    } catch (_) {
      return null;
    }
  }

  static ThemeMode _resolveInitialTheme(StorageService? storage) {
    return storage?.getAppThemeMode() ?? ThemeMode.system;
  }

  /// Basculer entre thème clair et sombre.
  /// Si [currentIsDark] est fourni, bascule de manière infaillible vers l'opposé du thème affiché.
  void toggleTheme({bool? currentIsDark}) {
    final ThemeMode newMode;
    if (currentIsDark != null) {
      newMode = currentIsDark ? ThemeMode.light : ThemeMode.dark;
    } else {
      if (state == ThemeMode.dark) {
        newMode = ThemeMode.light;
      } else {
        newMode = ThemeMode.dark;
      }
    }
    state = newMode;
    _storageService?.saveThemeMode(newMode);
  }

  /// Définir un mode de thème spécifique et le persister
  void setThemeMode(ThemeMode mode) {
    state = mode;
    _storageService?.saveThemeMode(mode);
  }
}

/// Provider global pour le thème de l'application LADAFURA
final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});
