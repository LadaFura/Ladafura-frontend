import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../shared/widgets/media/app_logo.dart';
import '../widgets/home_banner_widget.dart';
import '../widgets/home_quick_categories.dart';
import '../widgets/pharmacopee_home_card.dart';
import '../widgets/plante_home_card.dart';
import '../../providers/home_discovery_provider.dart';

/// Page d'accueil officielle de LADAFURA (Mode Citoyen & Découverte).
///
/// Identique à la page d'accueil Visiteur (bannière, catégories rapides,
/// pharmacopées à proximité, plantes les plus consultées),
/// sans les boutons de connexion / déconnexion.
class CitizenHomeScreen extends ConsumerWidget {
  const CitizenHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userLocationAsync = ref.watch(userLocationProvider);
    final userLocation = userLocationAsync.valueOrNull;

    final pharmacopeesAsync = ref.watch(nearbyPharmacopeesProvider);
    final plantesAsync = ref.watch(popularPlantesProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.surface,
      appBar: AppBar(
        title: const AppLogo.horizontal(height: 32),
        centerTitle: false,
        actions: [
          // Bascule de thème Clair / Sombre
          IconButton(
            tooltip: isDark ? 'Mode clair' : 'Mode sombre',
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_outlined,
              color: isDark ? Colors.white : AppColors.primary,
            ),
            onPressed: () {
              ref
                  .read(themeModeProvider.notifier)
                  .toggleTheme(currentIsDark: isDark);
            },
          ),

          // Icône cloche de notifications
          IconButton(
            tooltip: 'Notifications',
            icon: Icon(
              Icons.notifications_none_rounded,
              color: isDark ? Colors.white70 : const Color(0xFF1E272E),
              size: 26,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Aucune nouvelle notification pour le moment.'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          const SizedBox(width: AppDimensions.space8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.space16,
            vertical: AppDimensions.space12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Bannière Hero "La nature pour une meilleure santé"
              HomeBannerWidget(
                onTap: () => context.go(RouteNames.citizenRecherchePath),
              ),
              const SizedBox(height: AppDimensions.space20),

              // 2. Accès rapides aux 4 catégories (Pharmacopée, Fura, Plante, Maladie)
              HomeQuickCategories(
                onPharmacopeeTap: () => context.go(RouteNames.citizenCartePath),
                onFuraTap: () => context.go(RouteNames.citizenRecherchePath),
                onPlanteTap: () => context.go(RouteNames.citizenRecherchePath),
                onMaladieTap: () => context.go(RouteNames.citizenRecherchePath),
              ),
              const SizedBox(height: AppDimensions.space20),

              // 3. Section "Pharmacopées à proximité" (liste horizontale de plusieurs pharmacopées)
              _buildSectionHeader(
                context: context,
                title: 'Pharmacopées à proximité',
                onSeeAll: () => context.go(RouteNames.citizenCartePath),
                isDark: isDark,
              ),
              const SizedBox(height: AppDimensions.space12),

              pharmacopeesAsync.when(
                data: (pharmacopees) {
                  if (pharmacopees.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return SizedBox(
                    height: 250,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: pharmacopees.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(width: AppDimensions.space12),
                      itemBuilder: (context, index) {
                        final ph = pharmacopees[index];
                        return PharmacopeeHomeCard(
                          width: 300,
                          pharmacopee: ph,
                          userCoordinates: userLocation,
                          onTap: () => context.push(
                            RouteNames.citizenPharmacopeeDetailUrl(ph.id.toString()),
                          ),
                        );
                      },
                    ),
                  );
                },
                loading: () => const SizedBox(
                  height: 250,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: AppDimensions.space24),

              // 5. Section "Plantes les plus consultées"
              _buildSectionHeader(
                context: context,
                title: 'Plantes les plus consultées',
                onSeeAll: () => context.go(RouteNames.citizenRecherchePath),
                isDark: isDark,
              ),
              const SizedBox(height: AppDimensions.space12),

              plantesAsync.when(
                data: (plantes) {
                  if (plantes.isEmpty) return const SizedBox.shrink();
                  return SizedBox(
                    height: AppDimensions.cardPlantHomeHeight,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: plantes.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(width: AppDimensions.space12),
                      itemBuilder: (context, index) {
                        final plante = plantes[index];
                        return PlanteHomeCard(
                          plante: plante,
                          onTap: () => context.push(
                            RouteNames.citizenPlanteDetailUrl(
                                plante.id.toString()),
                          ),
                        );
                      },
                    ),
                  );
                },
                loading: () => const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: AppDimensions.space32),
            ],
          ),
        ),
      ),
    );
  }

  /// En-tête générique de section avec bouton "Voir tout >"
  Widget _buildSectionHeader({
    required BuildContext context,
    required String title,
    required VoidCallback onSeeAll,
    required bool isDark,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1E272E),
            ),
          ),
        ),
        const SizedBox(width: AppDimensions.space8),
        InkWell(
          onTap: onSeeAll,
          borderRadius: BorderRadius.circular(4),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Voir tout',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                SizedBox(width: 2),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: Color(0xFF2E7D32),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
