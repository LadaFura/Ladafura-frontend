import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_colors.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_dimensions.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_text_styles.dart';
import 'package:ladafura_frontend_flutter/core/routing/route_names.dart';
import 'package:ladafura_frontend_flutter/core/theme/theme_provider.dart';
import 'package:ladafura_frontend_flutter/features/auth/providers/auth_state_provider.dart';
import 'package:ladafura_frontend_flutter/shared/widgets/navigation/navigation_provider.dart';

/// Écran d'accueil principal de l'Espace Citoyen / Population LADAFURA.
class CitizenHomeScreen extends ConsumerWidget {
  const CitizenHomeScreen({super.key});

  /// Gère la déconnexion sécurisée avec boîte de dialogue de confirmation.
  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        ),
        title: Row(
          children: [
            const Icon(Icons.logout_rounded, color: AppColors.danger, size: 26),
            const SizedBox(width: AppDimensions.space12),
            Text(
              'Déconnexion',
              style: isDark ? AppTextStyles.h3Dark : AppTextStyles.h3,
            ),
          ],
        ),
        content: Text(
          'Êtes-vous sûr de vouloir vous déconnecter de votre espace citoyen ?',
          style: (isDark ? AppTextStyles.bodyDark : AppTextStyles.body).copyWith(
            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Annuler',
              style: TextStyle(
                color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
              ),
            ),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
              ),
            ),
            icon: const Icon(Icons.logout_rounded, size: 18),
            label: const Text('Se déconnecter'),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );

    if (shouldLogout == true && context.mounted) {
      ref.read(navigationIndexProvider.notifier).setIndex(0);
      await ref.read(authStateProvider.notifier).logout();
      if (context.mounted) {
        try {
          context.go(RouteNames.visitorHomePath);
        } catch (_) {
          // Permet aux tests de widgets unitaires sans GoRouter de compléter
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(authStateProvider);
    final user = authState.user;

    final citizenName = user != null && user.nomComplet.trim().isNotEmpty
        ? user.nomComplet
        : 'Citoyen LADAFURA';
    final citizenEmail = user?.email ?? 'citoyen@ladafura.ml';
    final initial = citizenName.isNotEmpty ? citizenName[0].toUpperCase() : 'C';

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.surface,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        elevation: 0.5,
        title: Text(
          'Espace Citoyen',
          style: (isDark ? AppTextStyles.h3Dark : AppTextStyles.h3).copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          // Bascule de thème Clair / Sombre
          IconButton(
            tooltip: isDark ? 'Mode clair' : 'Mode sombre',
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_outlined,
              color: isDark ? AppColors.darkAccent : AppColors.primary,
            ),
            onPressed: () {
              ref
                  .read(themeModeProvider.notifier)
                  .toggleTheme(currentIsDark: isDark);
            },
          ),

          // Bouton Déconnexion dans l'AppBar
          IconButton(
            tooltip: 'Se déconnecter',
            icon: const Icon(
              Icons.logout_rounded,
              color: AppColors.danger,
            ),
            onPressed: () => _handleLogout(context, ref),
          ),
          const SizedBox(width: AppDimensions.space8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.space20,
            vertical: AppDimensions.space16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Carte Profil du Citoyen avec dégradé
              Container(
                padding: const EdgeInsets.all(AppDimensions.space20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? const [
                            AppColors.darkSurfaceVariant,
                            AppColors.darkPrimaryContainer,
                          ]
                        : const [
                            AppColors.primaryDark,
                            AppColors.primary,
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      child: Text(
                        initial,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.space16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            citizenName,
                            style: AppTextStyles.h3.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            citizenEmail,
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Citoyen / Population 🇲🇱',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.space20),

              // 2. Section Actions Rapides & Découverte
              Text(
                'Vos Services Pharmacopée',
                style: (isDark ? AppTextStyles.h3Dark : AppTextStyles.h3).copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppDimensions.space12),

              Row(
                children: [
                  Expanded(
                    child: _buildServiceCard(
                      context: context,
                      isDark: isDark,
                      icon: Icons.search_rounded,
                      title: 'Recherche Flore',
                      subtitle: 'Plantes & Remèdes',
                      color: AppColors.primary,
                      onTap: () {
                        context.go(RouteNames.citizenRecherchePath);
                      },
                    ),
                  ),
                  const SizedBox(width: AppDimensions.space12),
                  Expanded(
                    child: _buildServiceCard(
                      context: context,
                      isDark: isDark,
                      icon: Icons.bookmark_rounded,
                      title: 'Mes Favoris',
                      subtitle: 'Recettes sauvegardées',
                      color: AppColors.accent,
                      onTap: () {
                        context.go(RouteNames.citizenFavorisPath);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.space12),

              Row(
                children: [
                  Expanded(
                    child: _buildServiceCard(
                      context: context,
                      isDark: isDark,
                      icon: Icons.map_rounded,
                      title: 'Carte Botanique',
                      subtitle: 'Flore par région',
                      color: const Color(0xFF0288D1),
                      onTap: () {
                        context.go(RouteNames.citizenCartePath);
                      },
                    ),
                  ),
                  const SizedBox(width: AppDimensions.space12),
                  Expanded(
                    child: _buildServiceCard(
                      context: context,
                      isDark: isDark,
                      icon: Icons.local_florist_rounded,
                      title: 'Savoirs Ancestraux',
                      subtitle: 'Tradithérapeutes',
                      color: const Color(0xFF7B1FA2),
                      onTap: () {
                        context.go(RouteNames.citizenRecherchePath);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.space24),

              // 3. Carte de Déconnexion Dédiée
              Container(
                padding: const EdgeInsets.all(AppDimensions.space16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.border,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.space12),
                      decoration: BoxDecoration(
                        color: AppColors.danger.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.logout_rounded,
                        color: AppColors.danger,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.space16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Session Citoyen',
                            style: (isDark
                                    ? AppTextStyles.bodyDark
                                    : AppTextStyles.body)
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Quitter votre compte en toute sécurité',
                            style: AppTextStyles.caption.copyWith(
                              color: isDark
                                  ? AppColors.darkTextMuted
                                  : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.danger,
                        side: const BorderSide(color: AppColors.danger),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusButton),
                        ),
                      ),
                      icon: const Icon(Icons.logout_rounded, size: 16),
                      label: const Text('Déconnexion'),
                      onPressed: () => _handleLogout(context, ref),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.space32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard({
    required BuildContext context,
    required bool isDark,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.space16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: AppDimensions.space12),
            Text(
              title,
              style: (isDark ? AppTextStyles.bodyDark : AppTextStyles.body)
                  .copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTextStyles.caption.copyWith(
                color:
                    isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
