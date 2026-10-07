import 'package:flutter/material.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_colors.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_dimensions.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_text_styles.dart';
import 'package:ladafura_frontend_flutter/features/recherche/models/global_search_response.dart';

/// Carte résultat d'un médicament traditionnel / préparation Fura (Section #4).
class SearchProduitCard extends StatelessWidget {
  final ProduitSearchItem produit;
  final VoidCallback onCommander;
  final bool isDark;

  const SearchProduitCard({
    super.key,
    required this.produit,
    required this.onCommander,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.space12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        side: BorderSide(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
      ),
      color: isDark ? AppColors.darkSurface : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.space12),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.medication_rounded,
                color: Color(0xFF1976D2),
                size: 26,
              ),
            ),
            const SizedBox(width: AppDimensions.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    produit.nom,
                    style: (isDark ? AppTextStyles.bodyDark : AppTextStyles.body)
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  if (produit.forme != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      produit.forme!,
                      style: AppTextStyles.caption.copyWith(
                        color: isDark
                            ? AppColors.darkTextMuted
                            : AppColors.textMuted,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    produit.prixFormate,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: const Size(0, 36),
              ),
              onPressed: onCommander,
              child: const Text('Commander', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }
}
