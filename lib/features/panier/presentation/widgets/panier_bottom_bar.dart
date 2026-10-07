import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';

/// Barre fixe inférieure du panier affichant le total et le bouton de validation de commande.
class PanierBottomBar extends StatelessWidget {
  final String montantTotalFormate;
  final bool isLoading;
  final VoidCallback onValider;

  const PanierBottomBar({
    super.key,
    required this.montantTotalFormate,
    required this.isLoading,
    required this.onValider,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkAccent : AppColors.primary;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.space16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 50 : 15),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total des produits :',
                  style: (isDark ? AppTextStyles.bodyDark : AppTextStyles.body)
                      .copyWith(fontSize: 15),
                ),
                Text(
                  montantTotalFormate,
                  style: (isDark ? AppTextStyles.h3Dark : AppTextStyles.h3).copyWith(
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Frais de mise à disposition :',
                  style: (isDark ? AppTextStyles.captionDark : AppTextStyles.caption)
                      .copyWith(fontSize: 12),
                ),
                Text(
                  'Calculés à l\'étape suivante',
                  style: (isDark ? AppTextStyles.captionDark : AppTextStyles.caption)
                      .copyWith(
                    fontStyle: FontStyle.italic,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.space16),
            PrimaryButton(
              label: 'Valider la commande',
              icon: Icons.check_circle_outline_rounded,
              isLoading: isLoading,
              onPressed: onValider,
            ),
          ],
        ),
      ),
    );
  }
}

