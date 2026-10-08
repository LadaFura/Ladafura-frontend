import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../models/paiement_model.dart';

/// Tuile de sélection d'une méthode de paiement (Orange Money, Moov, Wave, Cash).
class CommandeMethodePaiementTile extends StatelessWidget {
  final MethodePaiementModel methode;
  final bool isSelected;
  final VoidCallback onTap;

  const CommandeMethodePaiementTile({
    super.key,
    required this.methode,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.primary;

    final icon = methode.isMobileMoney
        ? Icons.phone_android_rounded
        : (methode.isCash
            ? Icons.payments_outlined
            : Icons.credit_card_rounded);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(AppDimensions.space12),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withAlpha(20)
              : (isDark ? AppColors.darkSurface : AppColors.surface),
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          border: Border.all(
            color: isSelected
                ? primaryColor
                : (isDark ? AppColors.darkBorder : AppColors.border),
            width: isSelected ? 1.5 : AppDimensions.cardBorderWidth,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? primaryColor
                  : (isDark ? Colors.grey[400] : Colors.grey[600]),
              size: 26,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    methode.libelle,
                    style: (isDark ? AppTextStyles.bodyDark : AppTextStyles.body)
                        .copyWith(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  if (methode.description.isNotEmpty)
                    Text(
                      methode.description,
                      style: (isDark
                              ? AppTextStyles.captionDark
                              : AppTextStyles.caption)
                          .copyWith(fontSize: 11),
                    ),
                ],
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? primaryColor : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

