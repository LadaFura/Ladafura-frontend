import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';

/// Élément d'action pour le groupe de paramètres
class ModernSettingItem {
  final IconData icon;
  final String title;
  final String? valueText;
  final Widget? trailingBadge;
  final Widget? customTrailing;
  final bool showChevron;
  final Color? iconColor;
  final Color? titleColor;
  final VoidCallback onTap;

  const ModernSettingItem({
    required this.icon,
    required this.title,
    this.valueText,
    this.trailingBadge,
    this.customTrailing,
    this.showChevron = true,
    this.iconColor,
    this.titleColor,
    required this.onTap,
  });
}

/// Carte de groupe moderne (fond blanc arrondi, bordure subtile, avec séparateurs fins)
/// fidèle au style iOS / Minimaliste de l'inspiration, intégrant le design system.
class ModernSettingSection extends StatelessWidget {
  final String? title;
  final List<ModernSettingItem> items;

  const ModernSettingSection({
    super.key,
    this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null && title!.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(
              left: AppDimensions.space4,
              bottom: AppDimensions.space8,
            ),
            child: Text(
              title!,
              style: (isDark
                      ? AppTextStyles.captionDark
                      : AppTextStyles.caption)
                  .copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
        Container(
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
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isLast = index == items.length - 1;

              return Column(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: item.onTap,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.space16,
                          vertical: AppDimensions.space12 + AppDimensions.space2,
                        ),
                        child: Row(
                          children: [
                            // Icône
                            Icon(
                              item.icon,
                              size: AppDimensions.iconSizeMedium,
                              color: item.iconColor ??
                                  (isDark
                                      ? Colors.white
                                      : AppColors.textSecondary),
                            ),
                            const SizedBox(width: AppDimensions.space12),

                            // Titre
                            Expanded(
                              child: Text(
                                item.title,
                                style: (isDark
                                        ? AppTextStyles.labelDark
                                        : AppTextStyles.label)
                                    .copyWith(
                                  color: item.titleColor,
                                ),
                              ),
                            ),

                            // Custom trailing (ex: Switch / Toggle) ou Badge / Valeur / Chevron
                            if (item.customTrailing != null)
                              item.customTrailing!
                            else ...[
                              if (item.trailingBadge != null)
                                item.trailingBadge!
                              else if (item.valueText != null)
                                Text(
                                  item.valueText!,
                                  style: isDark
                                      ? AppTextStyles.bodySecondaryDark
                                      : AppTextStyles.bodySecondary,
                                ),

                              if (item.showChevron) ...[
                                const SizedBox(width: AppDimensions.space8),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  size: AppDimensions.iconSizeMedium,
                                  color: isDark
                                      ? AppColors.darkTextMuted
                                      : AppColors.textMuted,
                                ),
                              ],
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (!isLast)
                    Divider(
                      height: 1,
                      thickness: 1,
                      indent: 48,
                      endIndent: AppDimensions.space16,
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.border.withAlpha(120),
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}
