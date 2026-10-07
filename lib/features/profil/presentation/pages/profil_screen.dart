import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../auth/providers/auth_state_provider.dart';
import '../../providers/profil_provider.dart';
import '../widgets/modern_profile_user_card.dart';
import '../widgets/modern_setting_section.dart';
import '../widgets/profil_logout_dialog.dart';

/// Page principale du Profil & Paramètres inspirée de l'interface moderne fournie.
/// Organisée en sections cartes arrondies avec titres clairs :
/// - En-tête : Avatar rond, Nom, Email, Action "Modifier mon profil"
/// - Détails du compte : Mes informations, Mes commandes
/// - Activités & Cible : Mes favoris, Mes notifications
/// - Général : Langue, Mode Sombre/Clair, Paramètres
/// - Assistance & Compte : À propos, Se déconnecter
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

  String _getThemeLabel(ThemeMode mode, bool isDarkSystem) {
    switch (mode) {
      case ThemeMode.light:
        return 'Clair';
      case ThemeMode.dark:
        return 'Sombre';
      case ThemeMode.system:
        return isDarkSystem ? 'Système (Sombre)' : 'Système (Clair)';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = ref.watch(authStateProvider);
    final profilState = ref.watch(profilProvider);
    final currentTheme = ref.watch(themeModeProvider);

    // Vérifier l'état d'authentification
    if (!auth.isAuthenticated) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: const Text('Profil'),
          centerTitle: true,
          automaticallyImplyLeading: false,
          elevation: 0,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.space24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_outline_rounded,
                    size: 64, color: Color(0xFF94A3B8)),
                const SizedBox(height: 16),
                const Text(
                  'Veuillez vous connecter pour accéder à votre profil.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => context.push(RouteNames.loginPath),
                  icon: const Icon(Icons.login_rounded),
                  label: const Text('Se connecter'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final profil = profilState.profil;
    final totalCommandes = profil?.nombreTotalCommandes ?? 0;
    final totalFavoris = profil?.nombreTotalFavoris ?? 0;
    final unreadNotifs = profilState.unreadNotificationsCount;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Profil & Paramètres',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Actualiser',
            icon: const Icon(Icons.refresh_rounded, size: 22),
            onPressed: () {
              ref.read(profilProvider.notifier).chargerProfil();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(profilProvider.notifier).chargerProfil(),
        child: profilState.isLoading && profil == null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.space16,
                  vertical: AppDimensions.space12,
                ),
                child: Column(
                  children: [
                    // 1. En-tête profil inspiré de la référence (Carte blanche arrondie)
                    ModernProfileUserCard(
                      profil: profil,
                      onEditProfile: () {
                        context.pushNamed(RouteNames.citizenModifierProfil);
                      },
                    ),
                    const SizedBox(height: AppDimensions.space20),

                    // 2. Section "Détails du compte" (Account details)
                    ModernSettingSection(
                      title: 'Détails du compte',
                      items: [
                        ModernSettingItem(
                          icon: Icons.person_outline_rounded,
                          title: 'Mes informations',
                          valueText: profil?.telephone ?? '',
                          onTap: () {
                            context.pushNamed(RouteNames.citizenModifierProfil);
                          },
                        ),
                        ModernSettingItem(
                          icon: Icons.receipt_long_outlined,
                          title: 'Mes commandes',
                          trailingBadge: totalCommandes > 0
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: (isDark ? AppColors.darkAccent : AppColors.primary).withAlpha(30),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '$totalCommandes',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? AppColors.darkAccent : AppColors.primary,
                                    ),
                                  ),
                                )
                              : null,
                          onTap: () {
                            context.pushNamed(RouteNames.citizenCommandes);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.space20),

                    // 3. Section "Activité & Favoris" (Target)
                    ModernSettingSection(
                      title: 'Activité & Favoris',
                      items: [
                        ModernSettingItem(
                          icon: Icons.favorite_border_rounded,
                          title: 'Mes remèdes favoris',
                          trailingBadge: totalFavoris > 0
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withAlpha(20),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '$totalFavoris',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                )
                              : null,
                          onTap: () {
                            context.pushNamed(RouteNames.citizenFavoris);
                          },
                        ),
                        ModernSettingItem(
                          icon: Icons.notifications_none_rounded,
                          title: 'Notifications',
                          trailingBadge: unreadNotifs > 0
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withAlpha(25),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '$unreadNotifs non lue${unreadNotifs > 1 ? 's' : ''}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange,
                                    ),
                                  ),
                                )
                              : null,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  unreadNotifs > 0
                                      ? 'Vous avez $unreadNotifs notification(s) non lue(s).'
                                      : 'Aucune nouvelle notification pour le moment.',
                                ),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.space20),

                    // 4. Section "Général" (General)
                    ModernSettingSection(
                      title: 'Général',
                      items: [
                        ModernSettingItem(
                          icon: Icons.language_rounded,
                          title: 'Langue',
                          valueText: 'Français',
                          onTap: () {
                            context.pushNamed(RouteNames.citizenParametres);
                          },
                        ),
                        ModernSettingItem(
                          icon: Icons.brightness_medium_outlined,
                          title: 'Mode Clair / Sombre',
                          valueText: _getThemeLabel(currentTheme, isDark),
                          onTap: () {
                            ref.read(themeModeProvider.notifier).toggleTheme(currentIsDark: isDark);
                          },
                        ),
                        ModernSettingItem(
                          icon: Icons.tune_rounded,
                          title: 'Paramètres avancés',
                          onTap: () {
                            context.pushNamed(RouteNames.citizenParametres);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.space20),

                    // 5. Section "Assistance & Session" (Support)
                    ModernSettingSection(
                      title: 'Assistance & Session',
                      items: [
                        ModernSettingItem(
                          icon: Icons.help_outline_rounded,
                          title: 'À propos de LADAFURA',
                          valueText: 'v1.0.0',
                          onTap: () {
                            context.pushNamed(RouteNames.citizenParametres);
                          },
                        ),
                        ModernSettingItem(
                          icon: Icons.logout_rounded,
                          title: 'Se déconnecter',
                          iconColor: const Color(0xFFEF4444),
                          titleColor: const Color(0xFFEF4444),
                          onTap: () => _handleLogout(context, ref),
                        ),
                      ],
                    ),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
      ),
    );
  }
}
