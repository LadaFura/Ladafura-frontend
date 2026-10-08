import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../models/mode_retrait_model.dart';

/// Sélecteur visuel des modes de mise à disposition (livraison, retrait comptoir).
class CommandeModeRetraitSelector extends StatelessWidget {
  final List<ModeRetraitOptionModel> options;
  final ModeRetraitOptionModel? selected;
  final ValueChanged<ModeRetraitOptionModel> onSelected;

  const CommandeModeRetraitSelector({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.primary;

    if (options.isEmpty) {
      return const Text(
          'Aucun mode de retrait configuré pour cette pharmacopée.');
    }

    return Column(
      children: options.map((opt) {
        final isSelected = selected?.id == opt.id;
        final isAvailable = opt.actif;
        final icon = opt.isLivraison
            ? Icons.delivery_dining_rounded
            : Icons.store_mall_directory_rounded;

        return InkWell(
          onTap: isAvailable ? () => onSelected(opt) : null,
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(AppDimensions.space12),
            decoration: BoxDecoration(
              color: !isAvailable
                  ? (isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF1F5F9))
                  : isSelected
                      ? primaryColor.withAlpha(20)
                      : (isDark ? AppColors.darkSurface : AppColors.surface),
              borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
              border: Border.all(
                color: !isAvailable
                    ? (isDark ? AppColors.darkBorder : AppColors.border)
                    : isSelected
                        ? primaryColor
                        : (isDark ? AppColors.darkBorder : AppColors.border),
                width: isSelected ? 1.5 : AppDimensions.cardBorderWidth,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: !isAvailable
                      ? AppColors.textMuted
                      : isSelected
                          ? primaryColor
                          : (isDark ? Colors.grey[400] : Colors.grey[600]),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        opt.libelle,
                        style: (isDark
                                ? AppTextStyles.bodyDark
                                : AppTextStyles.body)
                            .copyWith(
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      if (opt.description != null &&
                          opt.description!.isNotEmpty)
                        Text(
                          opt.description!,
                          style: (isDark
                                  ? AppTextStyles.captionDark
                                  : AppTextStyles.caption)
                              .copyWith(fontSize: 11),
                        ),
                    ],
                  ),
                ),
                Text(
                  opt.fraisFormate,
                  style: (isDark ? AppTextStyles.h4Dark : AppTextStyles.h4)
                      .copyWith(
                    fontWeight: FontWeight.bold,
                    color: opt.gratuit || opt.frais <= 0
                        ? Colors.green
                        : primaryColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
