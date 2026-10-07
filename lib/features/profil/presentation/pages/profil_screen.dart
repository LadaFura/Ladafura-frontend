import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/routing/route_names.dart';
import '../../../auth/providers/auth_state_provider.dart';
import '../../providers/profil_provider.dart';
import '../widgets/profil_activite_section.dart';
import '../widgets/profil_header.dart';
import '../widgets/profil_info_section.dart';
import '../widgets/profil_logout_dialog.dart';
import '../widgets/profil_reglages_section.dart';

/// Page principale du Profil Population (Citoyen).
class ProfilScreen extends ConsumerWidget {
  const ProfilScreen({super.key});

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final shouldLogout = await ProfilLogoutDialog.show(context);

    if (shouldLogout == true && context.mounted) {
      await ref.read(authStateProvider.notifier).logout();
      if (context.mounted) {
        context.go(RouteNames.loginPath);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = ref.watch(authStateProvider);
    final profilState = ref.watch(profilProvider);

    // Vérifier l'état d'authentification
    if (!auth.isAuthenticated) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.surface,
        appBar: AppBar(
          title: const Text('Mon Profil'),
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.space24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_outline_rounded,
                    size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Veuillez vous connecter pour accéder à votre profil.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => context.push(RouteNames.loginPath),
                  icon: const Icon(Icons.login_rounded),
                  label: const Text('Se connecter'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.surface,
      appBar: AppBar(
        title: const Text('Mon Profil'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: 'Actualiser',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              ref.read(profilProvider.notifier).chargerProfil();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(profilProvider.notifier).chargerProfil(),
        child: profilState.isLoading && profilState.profil == null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppDimensions.space16),
                child: Column(
                  children: [
                    // 1. En-tête : Avatar avec icône générique, identité et statut
                    ProfilHeader(profil: profilState.profil),
                    const SizedBox(height: AppDimensions.space16),

                    // 2. Mes informations : Nom, Prénom, Téléphone, Email + Action Modifier
                    ProfilInfoSection(
                      profil: profilState.profil,
                      onModifier: () {
                        context.pushNamed(RouteNames.citizenModifierProfil);
                      },
                    ),
                    const SizedBox(height: AppDimensions.space16),

                    // 3. Mon activité : Commandes, Favoris, Notifications avec compteurs réels
                    ProfilActiviteSection(
                      totalCommandes:
                          profilState.profil?.nombreTotalCommandes ?? 0,
                      totalFavoris:
                          profilState.profil?.nombreTotalFavoris ?? 0,
                      unreadNotifications:
                          profilState.unreadNotificationsCount,
                      onTapCommandes: () {
                        context.pushNamed(RouteNames.citizenCommandes);
                      },
                      onTapFavoris: () {
                        context.pushNamed(RouteNames.citizenFavoris);
                      },
                      onTapNotifications: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              profilState.unreadNotificationsCount > 0
                                  ? 'Vous avez ${profilState.unreadNotificationsCount} notification(s) non lue(s).'
                                  : 'Aucune nouvelle notification pour le moment.',
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: AppDimensions.space16),

                    // 4. Préférences & Déconnexion
                    ProfilReglagesSection(
                      onTapParametres: () {
                        context.pushNamed(RouteNames.citizenParametres);
                      },
                      onTapLogout: () => _handleLogout(context, ref),
                    ),
                    const SizedBox(height: AppDimensions.space24),
                  ],
                ),
              ),
      ),
    );
  }
}
