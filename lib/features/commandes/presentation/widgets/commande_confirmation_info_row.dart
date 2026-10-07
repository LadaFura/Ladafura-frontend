import 'package:flutter/material.dart';
import '../../../../core/constants/app_text_styles.dart';

/// Ligne d'information étiquette / valeur pour le récapitulatif de confirmation de commande.
class CommandeConfirmationInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  const CommandeConfirmationInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: (isDark ? AppTextStyles.captionDark : AppTextStyles.caption)
              .copyWith(fontSize: 13),
        ),
        Text(
          value,
          style: (isDark ? AppTextStyles.bodyDark : AppTextStyles.body).copyWith(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            fontSize: 13,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
