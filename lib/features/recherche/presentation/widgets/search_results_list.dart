import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_dimensions.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_text_styles.dart';
import 'package:ladafura_frontend_flutter/core/routing/route_names.dart';
import 'package:ladafura_frontend_flutter/features/recherche/models/global_search_response.dart';
import 'package:ladafura_frontend_flutter/features/recherche/providers/recherche_provider.dart';
import 'search_category_chips.dart';
import 'search_pharmacopee_card.dart';
import 'search_plante_card.dart';
import 'search_section_title.dart';

/// Widget dédié affichant la liste ordonnée des résultats de recherche.
/// Met en priorité les Pharmacopées agréées (pour consultation et achat de remèdes),
/// puis les Plantes médicinales (savoirs traditionnels & études).
class SearchResultsList extends StatelessWidget {
  final GlobalSearchResponse results;
  final SearchCategory category;
  final dynamic userLocation;
  final bool isCitizen;
  final bool isDark;
  final ValueChanged<SearchCategory> onCategorySelected;

  const SearchResultsList({
    super.key,
    required this.results,
    required this.category,
    required this.userLocation,
    required this.isCitizen,
    required this.isDark,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final showPharmacopees = (category == SearchCategory.all ||
            category == SearchCategory.pharmacopees) &&
        results.pharmacopees.isNotEmpty;

    final showPlantes = (category == SearchCategory.all ||
            category == SearchCategory.plantes) &&
        results.plantes.isNotEmpty;

    return ListView(
      padding: const EdgeInsets.all(AppDimensions.space16),
      children: [
        // Sélecteur de catégorie modulaire pour filtrer dynamiquement les résultats
        SearchCategoryChips(
          selectedCategory: category,
          onSelected: onCategorySelected,
          isDark: isDark,
        ),
        const SizedBox(height: AppDimensions.space12),

        if (!showPharmacopees && !showPlantes)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppDimensions.space32),
            child: Center(
              child: Text(
                'Aucune pharmacopée ou plante trouvée pour cette catégorie.',
                style: isDark ? AppTextStyles.bodyDark : AppTextStyles.body,
              ),
            ),
          ),

        // =====================================================================
        // SECTION 1 : PHARMACOPÉES AGRÉÉES (Consultation pour achat de remèdes)
        // =====================================================================
        if (showPharmacopees) ...[
          SearchSectionTitle(
            title: 'Pharmacopées traditionnelles',
            count: results.pharmacopees.length,
            isPriority: true,
            isDark: isDark,
          ),
          const SizedBox(height: AppDimensions.space8),
          ...results.pharmacopees.map(
            (pharma) => SearchPharmacopeeCard(
              pharma: pharma,
              userLocation: userLocation,
              onTap: () {
                final detailPath = isCitizen
                    ? RouteNames.citizenPharmacopeeDetailUrl(pharma.id.toString())
                    : RouteNames.visitorPharmacopeeDetailUrl(pharma.id.toString());
                context.push(detailPath);
              },
              isDark: isDark,
            ),
          ),
          const SizedBox(height: AppDimensions.space16),
        ],

        // =====================================================================
        // SECTION 2 : PLANTES MÉDICINALES (Savoirs & Études)
        // =====================================================================
        if (showPlantes) ...[
          SearchSectionTitle(
            title: 'Plantes Médicinales',
            count: results.plantes.length,
            isDark: isDark,
          ),
          const SizedBox(height: AppDimensions.space8),
          ...results.plantes.map(
            (plante) => SearchPlanteCard(
              plante: plante,
              onTap: () {
                final detailPath = isCitizen
                    ? RouteNames.citizenPlanteDetailUrl(plante.id.toString())
                    : RouteNames.visitorPlanteDetailUrl(plante.id.toString());
                context.push(detailPath);
              },
              isDark: isDark,
            ),
          ),
          const SizedBox(height: AppDimensions.space24),
        ],
      ],
    );
  }
}
