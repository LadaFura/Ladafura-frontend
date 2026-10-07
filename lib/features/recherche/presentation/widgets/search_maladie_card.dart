import 'package:flutter/material.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_colors.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_dimensions.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_text_styles.dart';
import 'package:ladafura_frontend_flutter/features/recherche/models/global_search_response.dart';

/// Carte résultat d'une pathologie/maladie ciblée (Section #3).
class SearchMaladieCard extends StatelessWidget {
  final MaladieSearchItem maladie;
  final VoidCallback onTap;
  final bool isDark;

  const SearchMaladieCard({
    super.key,
    required this.maladie,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.space8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        side: BorderSide(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
      ),
      color: isDark ? AppColors.darkSurface : Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3E0),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.healing_rounded,
            color: Color(0xFFF57C00),
            size: 22,
          ),
        ),
        title: Text(
          maladie.nom,
          style: (isDark ? AppTextStyles.bodyDark : AppTextStyles.body)
              .copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: maladie.description != null
            ? Text(
                maladie.description!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption,
              )
            : null,
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[800] : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${maladie.nombrePlantesAssociees} plantes',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
