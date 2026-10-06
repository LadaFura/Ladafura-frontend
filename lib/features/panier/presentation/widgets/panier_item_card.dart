import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../models/panier_item_model.dart';

class PanierItemCard extends StatelessWidget {
  final PanierItemModel item;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onRemove;

  const PanierItemCard({
    super.key,
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.space12),
      padding: const EdgeInsets.all(AppDimensions.space12),
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
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: (isDark ? AppColors.darkAccent : AppColors.primary)
                  .withAlpha(20),
              borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
            ),
            child: Icon(
              Icons.medication_liquid_rounded,
              color: isDark ? AppColors.darkAccent : AppColors.primary,
            ),
          ),
          const SizedBox(width: AppDimensions.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.produit.nom,
                  style: (isDark ? AppTextStyles.h4Dark : AppTextStyles.h4)
                      .copyWith(fontSize: 15),
                ),
                Text(
                  '${item.produit.prixIndicatif.toStringAsFixed(0)} FCFA',
                  style: isDark
                      ? AppTextStyles.captionDark
                      : AppTextStyles.caption,
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, size: 20),
                onPressed: () => onQuantityChanged(item.quantite - 1),
              ),
              Text(
                '${item.quantite}',
                style: (isDark ? AppTextStyles.h4Dark : AppTextStyles.h4)
                    .copyWith(fontSize: 14),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, size: 20),
                onPressed: () => onQuantityChanged(item.quantite + 1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
