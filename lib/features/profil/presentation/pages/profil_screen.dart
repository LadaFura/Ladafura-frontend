import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../auth/providers/auth_state_provider.dart';
import '../../providers/profil_provider.dart';
import '../widgets/modern_profile_user_card.dart';
import '../widgets/modern_setting_section.dart';
import '../widgets/profil_logout_dialog.dart';

/// Page principale du Profil & Paramètres inspirée de l'interface moderne fournie.
/// Intègre rigoureusement les constantes de design system (AppDimensions, AppTextStyles, AppColors).
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = ref.watch(authStateProvider);
    final profilState = ref.watch(profilProvider);

    // Vérifier l'état d'authentification
    if (!auth.isAuthenticated) {
      return Scaffold(
        backgroundColor:
            isDark ? AppColors.darkBackground : AppColors.background,
        appBar: AppBar(
          title: Text(
            'Profil',
            style: isDark ? AppTextStyles.h3Dark : AppTextStyles.h3,
          ),
          centerTitle: true,
          automaticallyImplyLeading: false,
          elevation: 0,
        ),
        body: Center(
          child: Padding(
            padding: AppDimensions.paddingModal,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.lock_outline_rounded,
                  size: AppDimensions.space64,
                  color: AppColors.textMuted,
                ),
                const SizedBox(height: AppDimensions.space16),
                Text(
                  'Veuillez vous connecter pour accéder à votre profil.',
                  textAlign: TextAlign.center,
                  style: isDark ? AppTextStyles.bodyDark : AppTextStyles.body,
                ),
                const SizedBox(height: AppDimensions.space20),
                ElevatedButton.icon(
                  onPressed: () => context.push(RouteNames.loginPath),
                  icon: const Icon(Icons.login_rounded),
                  label: Text('Se connecter', style: AppTextStyles.button),
                  style: ElevatedButton.styleFrom(
                    padding: AppDimensions.paddingButton,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusButton),
                    ),
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
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: Text(
          'Profil',
          style: isDark ? AppTextStyles.h3Dark : AppTextStyles.h3,
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Actualiser',
            icon: const Icon(
              Icons.refresh_rounded,
              size: AppDimensions.iconSizeLarge,
            ),
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
                  horizontal: AppDimensions.screenPaddingMobileH,
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
                                  padding: AppDimensions.paddingBadge,
                                  decoration: BoxDecoration(
                                    color: (isDark
                                            ? AppColors.darkPrimary
                                            : AppColors.primary)
                                        .withAlpha(30),
                                    borderRadius: BorderRadius.circular(
                                      AppDimensions.radiusBadge,
                                    ),
                                  ),
                                  child: Text(
                                    '$totalCommandes',
                                    style: AppTextStyles.badge.copyWith(
                                      color: isDark
                                          ? AppColors.darkPrimary
                                          : AppColors.primary,
                                      fontWeight: FontWeight.bold,
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
                                  padding: AppDimensions.paddingBadge,
                                  decoration: BoxDecoration(
                                    color: AppColors.danger.withAlpha(20),
                                    borderRadius: BorderRadius.circular(
                                      AppDimensions.radiusBadge,
                                    ),
                                  ),
                                  child: Text(
                                    '$totalFavoris',
                                    style: AppTextStyles.badge.copyWith(
                                      color: isDark
                                          ? AppColors.darkDanger
                                          : AppColors.danger,
                                      fontWeight: FontWeight.bold,
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
                                  padding: AppDimensions.paddingBadge,
                                  decoration: BoxDecoration(
                                    color: AppColors.warning.withAlpha(25),
                                    borderRadius: BorderRadius.circular(
                                      AppDimensions.radiusBadge,
                                    ),
                                  ),
                                  child: Text(
                                    '$unreadNotifs non lue${unreadNotifs > 1 ? 's' : ''}',
                                    style: AppTextStyles.badge.copyWith(
                                      color: isDark
                                          ? AppColors.darkWarning
                                          : AppColors.warning,
                                      fontWeight: FontWeight.bold,
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
                                  style: AppTextStyles.bodySecondary,
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
                          icon: isDark
                              ? Icons.dark_mode_rounded
                              : Icons.light_mode_rounded,
                          title: 'Mode Sombre',
                          iconColor: isDark ? Colors.white : AppColors.primary,
                          showChevron: false,
                          customTrailing: Switch.adaptive(
                            value: isDark,
                            activeThumbColor: AppColors.primary,
                            activeTrackColor: AppColors.primary.withAlpha(80),
                            onChanged: (val) {
                              ref
                                  .read(themeModeProvider.notifier)
                                  .setThemeMode(val ? ThemeMode.dark : ThemeMode.light);
                            },
                          ),
                          onTap: () {
                            ref
                                .read(themeModeProvider.notifier)
                                .toggleTheme(currentIsDark: isDark);
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
                          iconColor: AppColors.danger,
                          titleColor: AppColors.danger,
                          onTap: () => _handleLogout(context, ref),
                        ),
                      ],
                    ),
                    const SizedBox(
                        height: AppDimensions.space96 + AppDimensions.space24),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: const SizedBox(
        height: 110,
      ),
    );
  }
}
