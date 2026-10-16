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
import 'package:ladafura_frontend_flutter/features/notifications/providers/notification_provider.dart';
import 'package:ladafura_frontend_flutter/features/recherche/providers/recherche_provider.dart';

/// Page d'accueil officielle de LADAFURA (Mode Citoyen & Découverte).
///
/// Identique à la page d'accueil Visiteur (barre de recherche, carrousel d'inspiration,
/// 5 catégories rapides : Plantes, Produits, Maladies, Pharmacopées, Collectes,
/// pharmacopées à proximité, plantes les plus consultées).
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
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            ref.invalidate(nearbyPharmacopeesProvider);
            ref.invalidate(popularPlantesProvider);
            ref.invalidate(unreadNotificationCountProvider);
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
                  onTap: () => context.go(RouteNames.citizenRecherchePath),
                ),
              const SizedBox(height: AppDimensions.space16),

              // 2. Carrousel Hero "La richesse de notre pharmacopée traditionnelle"
              HomeBannerCarousel(
                onExplore: () => context.go(RouteNames.citizenRecherchePath),
              ),
              const SizedBox(height: AppDimensions.space20),

              // 3. Les 4 Catégories rapides : Plantes, Produits, Maladies, Pharmacopées
              HomeQuickCategories(
                onPlantesTap: () {
                  ref
                      .read(rechercheProvider.notifier)
                      .exploreCategory(SearchCategory.plantes, userLocation: userLocation);
                  context.go(RouteNames.citizenRecherchePath);
                },
                onProduitsTap: () => context.go(RouteNames.citizenRecherchePath),
                onMaladiesTap: () => context.go(RouteNames.citizenRecherchePath),
                onPharmacopeesTap: () => context.go(RouteNames.citizenCartePath),
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
                onSeeAll: () {
                  ref
                      .read(rechercheProvider.notifier)
                      .exploreCategory(SearchCategory.plantes, userLocation: userLocation);
                  context.go(RouteNames.citizenRecherchePath);
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
