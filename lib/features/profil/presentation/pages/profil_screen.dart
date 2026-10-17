import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../auth/providers/auth_state_provider.dart';
import '../../../notifications/providers/notification_provider.dart';
import '../../providers/profil_provider.dart';
import '../widgets/modern_profile_user_card.dart';
import '../widgets/modern_setting_section.dart';
import '../widgets/profil_logout_dialog.dart';

/// Page principale du Profil Citoyen / Population.
/// Design épuré sans duplication, avec navigation directe vers les notifications,
/// sélection de langue interactive, modal À propos et gestion du mode sombre.
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

  void _showLanguageSelector(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusModal),
        ),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.space20,
              vertical: AppDimensions.space16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.space16),
                Text(
                  'Langue de l\'application',
                  style: isDark ? AppTextStyles.h3Dark : AppTextStyles.h3,
                ),
                const SizedBox(height: AppDimensions.space16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Text('🇲🇱', style: TextStyle(fontSize: 26)),
                  title: Text(
                    'Français (Mali)',
                    style: (isDark ? AppTextStyles.bodyDark : AppTextStyles.body)
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text('Langue active'),
                  trailing: const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.primary,
                  ),
                  onTap: () => Navigator.pop(ctx),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Text('🇲🇱', style: TextStyle(fontSize: 26)),
                  title: Text(
                    'Bamanankan (Bambara)',
                    style: isDark ? AppTextStyles.bodyDark : AppTextStyles.body,
                  ),
                  subtitle: const Text('Bientôt disponible'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withAlpha(20),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Bientôt',
                      style: AppTextStyles.badge.copyWith(
                        color: AppColors.warning,
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Le support complet du Bamanankan arrive prochainement !',
                        ),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                const SizedBox(height: AppDimensions.space12),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusModal),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.space8),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.local_florist_rounded,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: AppDimensions.space12),
            Expanded(
              child: Text(
                'À propos de LADAFURA',
                style: isDark ? AppTextStyles.h4Dark : AppTextStyles.h4,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'LADAFURA Mobile v1.0.0 (Bêta)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppDimensions.space8),
            Text(
              'Plateforme numérique de référence pour la valorisation, la traçabilité et la diffusion sécurisée de la pharmacopée traditionnelle et des plantes médicinales.',
              style: isDark
                  ? AppTextStyles.bodySecondaryDark
                  : AppTextStyles.bodySecondary,
            ),
            const SizedBox(height: AppDimensions.space12),
            Text(
              '© 2026 LADAFURA. Tous droits réservés.',
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.white38 : AppColors.textMuted,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
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
    final unreadNotifs = ref.watch(unreadNotificationCountProvider).valueOrNull ??
        profilState.unreadNotificationsCount;

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
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            ref.read(profilProvider.notifier).chargerProfil(),
            ref.refresh(unreadNotificationCountProvider.future),
          ]);
        },
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
                    // 1. En-tête profil (Avatar, Nom, Email/Tel, Action "Modifier mon profil")
                    ModernProfileUserCard(
                      profil: profil,
                      onEditProfile: () {
                        context.pushNamed(RouteNames.citizenModifierProfil);
                      },
                    ),
                    const SizedBox(height: AppDimensions.space20),

                    // 2. Section "Mon Activité" (Commandes, Favoris, Notifications)
                    ModernSettingSection(
                      title: 'Mon Activité',
                      items: [
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
                            context.pushNamed(RouteNames.citizenNotifications);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.space20),

                    // 3. Section "Préférences" (Mode Sombre, Langue, Paramètres avancés)
                    ModernSettingSection(
                      title: 'Préférences',
                      items: [
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
                                  .setThemeMode(
                                      val ? ThemeMode.dark : ThemeMode.light);
                            },
                          ),
                          onTap: () {
                            ref
                                .read(themeModeProvider.notifier)
                                .toggleTheme(currentIsDark: isDark);
                          },
                        ),
                        ModernSettingItem(
                          icon: Icons.language_rounded,
                          title: 'Langue',
                          valueText: 'Français',
                          onTap: () => _showLanguageSelector(context, isDark),
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

                    // 4. Section "Assistance & Session"
                    ModernSettingSection(
                      title: 'Assistance & Session',
                      items: [
                        ModernSettingItem(
                          icon: Icons.info_outline_rounded,
                          title: 'À propos de LADAFURA',
                          valueText: 'v1.0.0',
                          onTap: () => _showAboutDialog(context, isDark),
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
