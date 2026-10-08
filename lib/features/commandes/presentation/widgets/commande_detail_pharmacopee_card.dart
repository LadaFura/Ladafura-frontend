import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../models/commande_model.dart';

/// Carte affichant les informations sur la pharmacopée / vendeur de la commande.
class CommandeDetailPharmacopeeCard extends StatelessWidget {
  final CommandeDetailModel commande;

  const CommandeDetailPharmacopeeCard({
    super.key,
    required this.commande,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.primary;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.space16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusModal),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
          width: AppDimensions.cardBorderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 16 : 4),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: primaryColor.withAlpha(20),
            radius: 20,
            child: Icon(Icons.storefront_rounded,
                color: primaryColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  commande.nomPharmacopee,
                  style: (isDark ? AppTextStyles.h4Dark : AppTextStyles.h4)
                      .copyWith(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                if (commande.telephonePharmacopee != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Tél : ${commande.telephonePharmacopee}',
                    style: (isDark
                            ? AppTextStyles.captionDark
                            : AppTextStyles.caption)
                        .copyWith(fontSize: 12),
                  ),
                ],
                if (commande.adressePharmacopee != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    commande.adressePharmacopee!,
                    style: (isDark
                            ? AppTextStyles.captionDark
                            : AppTextStyles.caption)
                        .copyWith(fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

