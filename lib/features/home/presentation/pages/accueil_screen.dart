import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../shared/widgets/media/app_logo.dart';
import '../widgets/home_banner_carousel.dart';
import '../widgets/home_quick_categories.dart';
import '../widgets/home_search_bar_button.dart';
import '../widgets/pharmacopee_home_card.dart';
import '../widgets/plante_home_card.dart';
import '../../providers/home_discovery_provider.dart';
import 'package:ladafura_frontend_flutter/features/recherche/providers/recherche_provider.dart';

/// Page d'accueil officielle de LADAFURA (Mode Visiteur & Découverte).
///
/// Conforme à l'interface moderne avec barre de recherche, carrousel d'inspiration
/// bannière "La richesse de notre pharmacopée traditionnelle", 5 catégories rapides
/// (Plantes, Produits, Maladies, Pharmacopées, Collectes) et cartes de découverte.
class AccueilScreen extends ConsumerWidget {
  const AccueilScreen({super.key});

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
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            ref.invalidate(nearbyPharmacopeesProvider);
            ref.invalidate(popularPlantesProvider);
            try {
              await Future.wait([
                ref.read(nearbyPharmacopeesProvider.future),
                ref.read(popularPlantesProvider.future),
              ]);
            } catch (_) {}
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.space16,
              vertical: AppDimensions.space12,
            ),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Barre de recherche redirigeant vers la recherche universelle
              HomeSearchBarButton(
                onTap: () => context.go(RouteNames.visitorRecherchePath),
              ),
              const SizedBox(height: AppDimensions.space16),

              // 2. Carrousel Hero "La richesse de notre pharmacopée traditionnelle"
              HomeBannerCarousel(
                onExplore: () => context.go(RouteNames.visitorRecherchePath),
              ),
              const SizedBox(height: AppDimensions.space20),

              // 3. Les 4 Catégories rapides : Plantes, Produits, Maladies, Pharmacopées
              HomeQuickCategories(
                onPlantesTap: () {
                  ref
                      .read(rechercheProvider.notifier)
                      .exploreCategory(SearchCategory.plantes, userLocation: userLocation);
                  context.go(RouteNames.visitorRecherchePath);
                },
                onProduitsTap: () => context.go(RouteNames.visitorRecherchePath),
                onMaladiesTap: () => context.go(RouteNames.visitorRecherchePath),
                onPharmacopeesTap: () => context.go(RouteNames.visitorCartePath),
              ),
              const SizedBox(height: AppDimensions.space20),

              // 3. Section "Pharmacopées à proximité" (liste horizontale de plusieurs pharmacopées)
              _buildSectionHeader(
                context: context,
                title: 'Pharmacopées à proximité',
                onSeeAll: () => context.go(RouteNames.visitorCartePath),
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
                            RouteNames.visitorPharmacopeeDetailUrl(ph.id.toString()),
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
                onSeeAll: () {
                  ref
                      .read(rechercheProvider.notifier)
                      .exploreCategory(SearchCategory.plantes, userLocation: userLocation);
                  context.go(RouteNames.visitorRecherchePath);
                },
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
                            RouteNames.visitorPlanteDetailUrl(
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
              const SizedBox(height: AppDimensions.space24),

              // 6. Section Agent de Collecte Terrain
              _buildAgentSection(context, isDark),
              const SizedBox(height: AppDimensions.space32),
            ],
          ),
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

  /// Bannière d'accès direct pour les agents de collecte
  Widget _buildAgentSection(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.space16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : const Color(0xFFF1F8E9),
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : const Color(0xFFC8E6C9),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.space12),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.assignment_ind_rounded,
              color: Color(0xFF2E7D32),
              size: 26,
            ),
          ),
          const SizedBox(width: AppDimensions.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vous êtes agent de collecte ?',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1E272E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Connectez-vous pour enregistrer vos collectes sur le terrain.',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : const Color(0xFF616161),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.space8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 36),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.space12,
                vertical: AppDimensions.space8,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
              ),
            ),
            onPressed: () => context.go(RouteNames.loginPath),
            child: const Text(
              'Connexion',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
