import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../buttons/primary_button.dart';

/// Vue d'erreur réseau ou technique avec message clair et bouton 'Réessayer'.
class AppErrorWidget extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final String retryLabel;
  final IconData icon;

  const AppErrorWidget({
    super.key,
    this.title = 'Une erreur est survenue',
    required this.message,
    this.onRetry,
    this.retryLabel = 'Réessayer',
    this.icon = Icons.wifi_off_outlined,
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
                color: AppColors.danger.withValues(alpha: 0.12),
              ),
              child: Icon(
                icon,
                size: 48,
                color: AppColors.danger,
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
            if (onRetry != null) ...[
              const SizedBox(height: AppDimensions.space24),
              PrimaryButton(
                label: retryLabel,
                icon: Icons.refresh,
                onPressed: onRetry,
                width: 200,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
