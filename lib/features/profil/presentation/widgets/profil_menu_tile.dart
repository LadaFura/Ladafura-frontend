import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';

class ProfilMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Color? iconColor;

  const ProfilMenuTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
      ),
      leading: Icon(
        icon,
        color: iconColor ?? (isDark ? AppColors.darkPrimary : AppColors.primary),
      ),
      title: Text(
        title,
        style: isDark ? AppTextStyles.bodyDark : AppTextStyles.body,
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: isDark
                  ? AppTextStyles.captionDark
                  : AppTextStyles.caption,
            )
          : null,
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textMuted,
      ),
    );
  }
}
