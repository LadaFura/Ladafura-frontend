import 'package:flutter/material.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_colors.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_dimensions.dart';
import 'package:ladafura_frontend_flutter/features/recherche/providers/recherche_provider.dart';

/// Barre de défilement horizontal des puces de catégories de recherche.
class SearchCategoryChips extends StatelessWidget {
  final SearchCategory selectedCategory;
  final ValueChanged<SearchCategory> onSelected;
  final bool isDark;

  const SearchCategoryChips({
    super.key,
    required this.selectedCategory,
    required this.onSelected,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.space16,
        ),
        itemCount: SearchCategory.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppDimensions.space8),
        itemBuilder: (context, index) {
          final cat = SearchCategory.values[index];
          final isSelected = selectedCategory == cat;
          return ChoiceChip(
            label: Text(cat.label),
            selected: isSelected,
            onSelected: (_) => onSelected(cat),
            selectedColor: AppColors.primary,
            backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
            labelStyle: TextStyle(
              color: isSelected
                  ? Colors.white
                  : (isDark ? Colors.white70 : AppColors.textPrimary),
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? AppColors.darkBorder : AppColors.border),
              ),
            ),
          );
        },
      ),
    );
  }
}
