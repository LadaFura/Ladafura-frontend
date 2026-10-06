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
import '../widgets/profil_menu_tile.dart';

/// Page Profil du Citoyen (Navigation principale).
class ProfilScreen extends ConsumerWidget {
  const ProfilScreen({super.key});

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Voulez-vous vraiment vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );

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
    final profilAsync = ref.watch(citoyenProfilProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.surface,
      appBar: AppBar(
        title: const Text('Mon Profil'),
        automaticallyImplyLeading: false, // Pas d'icône de retour sur page principale
      ),
      body: profilAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Erreur de chargement')),
        data: (profil) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.space16),
            child: Column(
              children: [
                // En-tête Avatar & Identité
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: (isDark
                                ? AppColors.darkAccent
                                : AppColors.primary)
                            .withAlpha(30),
                        child: Text(
                          profil?.prenom.isNotEmpty == true
                              ? profil!.prenom[0].toUpperCase()
                              : 'C',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.darkAccent
                                : AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.space12),
                      Text(
                        profil?.nomComplet ?? 'Citoyen LADAFURA',
                        style: isDark ? AppTextStyles.h2Dark : AppTextStyles.h2,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        profil?.email ?? 'citoyen@ladafura.ml',
                        style: isDark
                            ? AppTextStyles.captionDark
                            : AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppDimensions.space24),
                const Divider(),

                // Menu items
                ProfilMenuTile(
                  icon: Icons.history_rounded,
                  title: 'Mes commandes',
                  subtitle: 'Consulter mes commandes de remèdes',
                  onTap: () {
                    context.pushNamed(RouteNames.citizenCommandes);
                  },
                ),
                ProfilMenuTile(
                  icon: Icons.favorite_border_rounded,
                  title: 'Mes plantes favorites',
                  subtitle: 'Accès rapide à vos plantes enregistrées',
                  onTap: () {},
                ),
                ProfilMenuTile(
                  icon: Icons.notifications_none_rounded,
                  title: 'Notifications',
                  onTap: () {},
                ),
                ProfilMenuTile(
                  icon: isDark
                      ? Icons.light_mode_outlined
                      : Icons.dark_mode_outlined,
                  title: isDark ? 'Mode clair' : 'Mode sombre',
                  onTap: () {
                    ref
                        .read(themeModeProvider.notifier)
                        .toggleTheme(currentIsDark: isDark);
                  },
                ),
                const Divider(),
                ProfilMenuTile(
                  icon: Icons.logout_rounded,
                  iconColor: AppColors.danger,
                  title: 'Se déconnecter',
                  onTap: () => _handleLogout(context, ref),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
