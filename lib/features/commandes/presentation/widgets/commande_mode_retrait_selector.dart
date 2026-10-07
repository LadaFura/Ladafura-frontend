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
    final primaryColor = isDark ? AppColors.darkAccent : AppColors.primary;

    if (options.isEmpty) {
      return const Text(
          'Aucun mode de retrait configuré pour cette pharmacopée.');
    }

    return Column(
      children: options.map((opt) {
        final isSelected = selected?.id == opt.id;
        final isEnabled = opt.actif;
        final icon = opt.isLivraison
            ? Icons.delivery_dining_rounded
            : Icons.store_mall_directory_rounded;

        return Opacity(
          opacity: isEnabled ? 1.0 : 0.5,
          child: InkWell(
            onTap: isEnabled ? () => onSelected(opt) : null,
            borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(AppDimensions.space12),
              decoration: BoxDecoration(
                color: isSelected
                    ? primaryColor.withAlpha(20)
                    : (isDark ? AppColors.darkSurface : Colors.white),
                borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                border: Border.all(
                  color: isSelected
                      ? primaryColor
                      : (isDark ? AppColors.darkBorder : AppColors.border),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: isSelected
                        ? primaryColor
                        : (isDark ? Colors.grey[400] : Colors.grey[600]),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
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
                            if (!isEnabled) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withAlpha(50),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Indisponible',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
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
                    isEnabled ? opt.fraisFormate : 'Indisponible',
                    style: (isDark ? AppTextStyles.h4Dark : AppTextStyles.h4)
                        .copyWith(
                      fontWeight: FontWeight.bold,
                      color: !isEnabled
                          ? Colors.grey
                          : (opt.gratuit || opt.frais <= 0
                              ? Colors.green
                              : primaryColor),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
