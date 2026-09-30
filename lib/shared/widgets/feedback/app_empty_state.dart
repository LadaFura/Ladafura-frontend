import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../buttons/primary_button.dart';

/// Vue d'état vide affichée lorsqu'aucun résultat, panier, commande ou collecte n'est trouvé.
class AppEmptyState extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  const AppEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.space20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? AppColors.darkPrimaryContainer
                    : AppColors.primaryLight,
              ),
              child: Icon(
                icon,
                size: 48,
                color: isDark ? AppColors.darkPrimary : AppColors.primary,
              ),
            ),
            const SizedBox(height: AppDimensions.space20),
            Text(
              title,
              style: isDark ? AppTextStyles.h3Dark : AppTextStyles.h3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.space8),
            Text(
              message,
              style: (isDark
                      ? AppTextStyles.bodySecondaryDark
                      : AppTextStyles.bodySecondary)
                  .copyWith(
                color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppDimensions.space24),
              PrimaryButton(
                label: actionLabel!,
                onPressed: onAction,
                width: 220,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
