import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';

/// Formulaire de saisie du numéro et de choix de l'opérateur pour Mobile Money avec logos officiels.
class CommandeMobileMoneyForm extends StatelessWidget {
  final List<String> operateurs;
  final String? selectedOperateur;
  final ValueChanged<String> onOperateurSelected;
  final TextEditingController telephoneController;
  final String? instructions;

  const CommandeMobileMoneyForm({
    super.key,
    required this.operateurs,
    required this.selectedOperateur,
    required this.onOperateurSelected,
    required this.telephoneController,
    this.instructions,
  });

  String? _getLogoAsset(String op) {
    final lower = op.toLowerCase();
    if (lower.contains('orange')) {
      return 'assets/images/Orange_small_logo.png';
    } else if (lower.contains('moov') || lower.contains('malitel')) {
      return 'assets/images/logo-malitel.png';
    } else if (lower.contains('wave')) {
      return 'assets/images/logo-wave.jpeg';
    }
    return null;
  }

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
            color: Colors.black.withValues(alpha: isDark ? 0.08 : 0.03),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Opérateur Mobile Money au Mali',
            style: (isDark ? AppTextStyles.captionDark : AppTextStyles.caption)
                .copyWith(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: operateurs.map((op) {
              final isOpSelected = selectedOperateur == op;
              final logoAsset = _getLogoAsset(op);

              return InkWell(
                onTap: () => onOperateurSelected(op),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isOpSelected
                        ? primaryColor.withValues(alpha: isDark ? 0.25 : 0.12)
                        : (isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.white),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isOpSelected
                          ? primaryColor
                          : (isDark
                              ? AppColors.darkBorder
                              : const Color(0xFFCBD5E1)),
                      width: isOpSelected ? 1.6 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (logoAsset != null) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.asset(
                            logoAsset,
                            width: 24,
                            height: 24,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.phone_android_rounded,
                              size: 20,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        op,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              isOpSelected ? FontWeight.bold : FontWeight.w600,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      if (isOpSelected) ...[
                        const SizedBox(width: 6),
                        Icon(
                          Icons.check_circle_rounded,
                          size: 16,
                          color: primaryColor,
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: telephoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Numéro de téléphone mobile (+223)',
              hintText: 'Ex: 70 11 22 33',
              prefixIcon: const Icon(Icons.phone_outlined, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          if (instructions != null && instructions!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              instructions!,
              style: (isDark ? AppTextStyles.captionDark : AppTextStyles.caption)
                  .copyWith(fontSize: 11.5, height: 1.4),
            ),
          ],
        ],
      ),
    );
  }
}
