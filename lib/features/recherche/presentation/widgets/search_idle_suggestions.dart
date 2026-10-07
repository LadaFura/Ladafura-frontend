import 'package:flutter/material.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_colors.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_dimensions.dart';
import '../../providers/recherche_provider.dart';

/// Vue par défaut affichant les recherches récentes dynamiques,
/// les sélecteurs de catégorie et les maladies populaires.
///
/// Conforme à la maquette UI officielle LADAFURA.
class SearchIdleSuggestions extends StatelessWidget {
  final List<String> recentSearches;
  final List<String> maladies;
  final ValueChanged<String>? onRemoveRecent;
  final VoidCallback? onClearAllRecent;
  final ValueChanged<String> onSelectTerm;
  final ValueChanged<SearchCategory> onSelectCategory;
  final SearchCategory selectedCategory;
  final bool isDark;

  const SearchIdleSuggestions({
    super.key,
    this.recentSearches = const [],
    this.maladies = const [
      'Diabète',
      'Hypertension',
      'Fatigue',
      'Digestion',
      'Anémie',
      'Toux',
      'Paludisme',
    ],
    this.onRemoveRecent,
    this.onClearAllRecent,
    required this.onSelectTerm,
    required this.onSelectCategory,
    required this.selectedCategory,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space16,
        vertical: AppDimensions.space12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Vos recherches récentes (Dynamique)
          if (recentSearches.isNotEmpty) ...[
            Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 18,
                  color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1E2822),
                ),
                const SizedBox(width: AppDimensions.space8),
                Text(
                  'Vos recherches récentes',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1E2822),
                  ),
                ),
                const Spacer(),
                if (onClearAllRecent != null)
                  TextButton(
                    onPressed: onClearAllRecent,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(50, 24),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Effacer',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppDimensions.space12),

            Wrap(
              spacing: AppDimensions.space8,
              runSpacing: AppDimensions.space8,
              children: recentSearches.map((term) {
                return InkWell(
                  onTap: () => onSelectTerm(term),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusBadge),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkSurface
                          : const Color(0xFFDCEAD9),
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusBadge),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          term,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : const Color(0xFF245037),
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          key: ValueKey('remove_$term'),
                          behavior: HitTestBehavior.opaque,
                          onTap: () => onRemoveRecent?.call(term),
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Icon(
                              Icons.close,
                              size: 14,
                              color: isDark
                                  ? AppColors.darkTextMuted
                                  : const Color(0xFF4A6B56),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppDimensions.space24),
          ],

          // 2. Cartes de catégories rapides (Tous, Pharmacopée, Plante)
          SizedBox(
            height: 64,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildCategoryCard(
                  label: 'Tous',
                  icon: Icons.spa_rounded,
                  category: SearchCategory.all,
                  isSelected: selectedCategory == SearchCategory.all,
                  isDark: isDark,
                ),
                const SizedBox(width: AppDimensions.space12),
                _buildCategoryCard(
                  label: 'Pharmacopée',
                  icon: Icons.account_balance_rounded,
                  category: SearchCategory.pharmacopees,
                  isSelected: selectedCategory == SearchCategory.pharmacopees,
                  isDark: isDark,
                ),
                const SizedBox(width: AppDimensions.space12),
                _buildCategoryCard(
                  label: 'Plante',
                  icon: Icons.eco_rounded,
                  category: SearchCategory.plantes,
                  isSelected: selectedCategory == SearchCategory.plantes,
                  isDark: isDark,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.space24),

          // 3. Maladies les plus recherchées
          Row(
            children: [
              Icon(
                Icons.favorite_rounded,
                size: 18,
                color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1E2822),
              ),
              const SizedBox(width: AppDimensions.space8),
              Text(
                'Maladies les plus recherchées',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1E2822),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space12),

          Wrap(
            spacing: AppDimensions.space8,
            runSpacing: AppDimensions.space8,
            children: maladies.map((maladie) {
              return InkWell(
                onTap: () => onSelectTerm(maladie),
                borderRadius: BorderRadius.circular(AppDimensions.radiusBadge),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurface
                        : const Color(0xFFE2EFE0),
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusBadge),
                  ),
                  child: Text(
                    maladie,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : const Color(0xFF245037),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard({
    required String label,
    required IconData icon,
    required SearchCategory category,
    required bool isSelected,
    required bool isDark,
  }) {
    final borderColor = isSelected
        ? AppColors.primary
        : (isDark ? AppColors.darkBorder : const Color(0xFFDDE5E0));

    return InkWell(
      onTap: () => onSelectCategory(category),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Color(0xFFDCEAD9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: const Color(0xFF2E7D32),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1E2822),
              ),
            ),
            const SizedBox(width: 12),
            const Icon(
              Icons.chevron_right,
              size: 18,
              color: Color(0xFF6B7B70),
            ),
          ],
        ),
      ),
    );
  }
}
