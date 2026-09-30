import 'package:flutter/material.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_colors.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_dimensions.dart';
import 'package:ladafura_frontend_flutter/core/constants/app_text_styles.dart';
import 'package:ladafura_frontend_flutter/shared/utils/validators.dart';

/// Champ de saisie adapté aux numéros de téléphone de la République du Mali (+223).
class PhoneInputField extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final bool isRequired;
  final String? label;

  const PhoneInputField({
    super.key,
    this.controller,
    this.onChanged,
    this.isRequired = false,
    this.label = 'Numéro de téléphone',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fillColor = isDark ? AppColors.darkSurface : AppColors.surface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.primary;
    final textColor =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final hintColor = isDark ? AppColors.darkTextMuted : AppColors.textMuted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: isDark ? AppTextStyles.labelDark : AppTextStyles.label,
          ),
          const SizedBox(height: AppDimensions.space8),
        ],
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.phone,
          onChanged: onChanged,
          validator: (val) =>
              AppValidators.phoneMali(val, isRequired: isRequired),
          style: AppTextStyles.body.copyWith(color: textColor),
          decoration: InputDecoration(
            hintText: '70 12 34 56',
            hintStyle: AppTextStyles.bodySecondary.copyWith(color: hintColor),
            filled: true,
            fillColor: fillColor,
            prefixIcon: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppDimensions.space12),
              margin: const EdgeInsets.only(right: AppDimensions.space8),
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(color: borderColor, width: 1.0),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drapeau du Mali symbolique ou texte
                  const Text('🇲🇱', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 6),
                  Text(
                    '+223',
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.space16,
              vertical: AppDimensions.space12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
              borderSide: BorderSide(color: borderColor, width: 1.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
              borderSide: BorderSide(color: borderColor, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
              borderSide: BorderSide(color: primaryColor, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
              borderSide: const BorderSide(color: AppColors.danger, width: 1.0),
            ),
          ),
        ),
      ],
    );
  }
}
