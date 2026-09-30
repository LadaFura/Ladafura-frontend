import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';

/// Indicateur de chargement centralisé et harmonisé avec l'identité LADAFURA.
class AppLoadingIndicator extends StatelessWidget {
  final String? message;
  final double size;
  final Color? color;

  const AppLoadingIndicator({
    super.key,
    this.message,
    this.size = 36.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary =
        color ?? (isDark ? AppColors.darkPrimary : AppColors.primary);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: 3.0,
              valueColor: AlwaysStoppedAnimation<Color>(primary),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: AppDimensions.space16),
            Text(
              message!,
              style: (isDark
                      ? AppTextStyles.bodySecondaryDark
                      : AppTextStyles.bodySecondary)
                  .copyWith(fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
